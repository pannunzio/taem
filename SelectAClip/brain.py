#brain == server. relays information
import argparse
import pythonosc
from pythonosc import dispatcher as dispatch
from pythonosc import osc_server
from pythonosc import osc_message_builder
from pythonosc import udp_client

#client info
clientParser = argparse.ArgumentParser()
clientParser.add_argument("--ip",
    default="127.0.0.1", help="The ip to talk on")
clientParser.add_argument("--port",
    type=int, default=11999, help="The port to talk on")
argClient = clientParser.parse_args()

client = udp_client.UDPClient(argClient.ip, argClient.port)

def fromRA(info, arg1):
    msg = osc_message_builder.OscMessageBuilder(address = "/brain")
    msg.add_arg(sentence)
    msg = msg.build()
    #print("msg: " + str(msg))
    client.send(msg)

def fromMouth(info, arg1):
    msg = osc_message_builder.OscMessageBuilder(address = "/brain")
    msg.add_arg(sentence)
    msg = msg.build()
    #print("msg: " + str(msg))
    client.send(msg)

def fromEars(info, arg1):
    msg = osc_message_builder.OscMessageBuilder(address = "/brain")
    msg.add_arg(sentence)
    msg = msg.build()
    #print("msg: " + str(msg))
    client.send(msg)

def fromBrain(info, arg1):
    msg = osc_message_builder.OscMessageBuilder(address = "/brain")
    msg.add_arg(sentence)
    msg = msg.build()
    #print("msg: " + str(msg))
    client.send(msg)

def print_volume_handler(unused_addr, args, volume):
    print("[{0}] ~ {1}".format(args[0], volume))

def print_compute_handler(unused_addr, args, volume):
    try:
        print("[{0}] ~ {1}".format(args[0], args[1](volume)))
    except ValueError:
        pass

if __name__ == "__main__":
  #server info
  #since i'm only using OSC locally, it's just gonna be from localhost to localhost
  brain = argparse.ArgumentParser()
  brain.add_argument("--ip",
      default="127.0.0.1", help="The ip to listen for sensory stimuli")
  brain.add_argument("--port",
      type=int, default=12000, help="The port to listen for sensory stimuli")
  argServer = brain.parse_args()

  #this guy hears what's happening in the server. we cant use other functions bc server works on an infinite loop.
  #responds to trigger calls only!!
  dispatcher = dispatch.Dispatcher()

  #processing sketch speaks with clips, python sketch hears with a microphone
  dispatcher.map("/mouth", fromMouth)
  dispatcher.map("/researchAssistant", fromRA)
  dispatcher.map("/brain", fromBrain)
  dispatcher.map("/ears", fromEars)

  #below are required for the server not to crash
  dispatcher.map("/volume", print_volume_handler, "Volume")
  dispatcher.map("/logvolume", print_compute_handler, "Log volume", math.log)

  server = osc_server.ThreadingOSCUDPServer(
      (argServer.ip, argServer.port), dispatcher)
  print("Server Address: {}".format(server.server_address))
  server.serve_forever()
