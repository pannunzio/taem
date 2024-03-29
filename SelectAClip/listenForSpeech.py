import argparse
import math
import pythonosc
import speech_recognition as speechRec
import pyttsx3
import urllib.request
from pythonosc import dispatcher as dispatch
from pythonosc import osc_server
from pythonosc import osc_message_builder
from pythonosc import udp_client
from typing import List, Any

#client info
clientParser = argparse.ArgumentParser()
clientParser.add_argument("--ip",
    default="127.0.0.1", help="The ip to talk on")
clientParser.add_argument("--port",
    type=int, default=12042, help="The port to talk on")
argClient = clientParser.parse_args()

client_ra = udp_client.UDPClient(argClient.ip, argClient.port)

clientParser = argparse.ArgumentParser()
clientParser.add_argument("--ip",
    default="127.0.0.1", help="The ip to talk on")
clientParser.add_argument("--port",
    type=int, default=12103, help="The port to talk on")
argClient = clientParser.parse_args()

client_mouth = udp_client.UDPClient(argClient.ip, argClient.port)

def pry():
    recognizer = speechRec.Recognizer()
    mic = speechRec.Microphone()
    value = None
    try:
        with mic as source:
            recognizer.adjust_for_ambient_noise(source)
        recognizer.dynamic_energy_threshold = True
    #    print("Set minimum energy threshold to {}".format(recognizer.energy_threshold))
     #   print("Detecting audio...")

     ##TO DO: quick triggers to monitor audience. then IF speaking is detected, monitor for longer peroods of time.
     # refer to this link: https://github.com/Uberi/speech_recognition/blob/master/reference/library-reference.rst
        try:
            with mic as source:
                audio = recognizer.listen(source, 10.0, 5.0, None)
                #audio = recognizer.listen(source)
            try:
                value = recognizer.recognize_google(audio)
                print("value: {}".format(value))
            except speechRec.UnknownValueError:
                return None
            except Exception as e:
                print(e)
                return None
        except speechRec.RequestError as e:
    #        print("Uh oh! Couldn't request results from Google Speech Recognition service; {0}".format(e))
            return None
    except KeyboardInterrupt:
        return "error"
    return value

def print_volume_handler(unused_addr, args, volume):
  print("[{0}] ~ {1}".format(args[0], volume))

def print_compute_handler(unused_addr, args, volume):
  try:
    print("[{0}] ~ {1}".format(args[0], args[1](volume)))
  except ValueError: pass

def earsToHear(address: str, *args: List[Any]):
    print("trigger received from Mouth")
    msg = osc_message_builder.OscMessageBuilder(address = "/brain")
    try:
        print("calling listener")
        sentence = pry()
        while sentence is None:
            sentence = pry()
        #print("the sentence: " + sentence)

        string = sentence.split()
        for i in range(len(string)):
            msg.add_arg(string[i])

        msg = msg.build()
        #print("msg: " + str(msg))
        client_ra.send(msg)
        client_mouth.send(msg)
    except Exception as e:
        print(e)

if __name__ == "__main__":
  #server info
  #since i'm only using OSC locally, it's just gonna be from localhost to localhost
  serverParser = argparse.ArgumentParser()
  serverParser.add_argument("--ip",
      default="127.0.0.1", help="The ip to listen on")
  serverParser.add_argument("--port",
      type=int, default=12001, help="The port to listen on")
  argServer = serverParser.parse_args()

  #this guy hears what's happening in the server. we cant use other functions bc server works on an infinite loop.
  #responds to trigger calls only!!
  dispatcher = dispatch.Dispatcher()

  #processing sketch speaks with clips, python sketch hears with a microphone
  dispatcher.map("/mouth", earsToHear)

  #below are required for the server not to crash
  dispatcher.map("/volume", print_volume_handler, "Volume")
  dispatcher.map("/logvolume", print_compute_handler, "Log volume", math.log)

  server = osc_server.ThreadingOSCUDPServer(
      (argServer.ip, argServer.port), dispatcher)
  print("Server Address: {}".format(server.server_address))
  server.serve_forever()
