import argparse
import math
import pythonosc
import json
import requests
import urllib.request
import urllib.parse
import pymysql
from pythonosc import dispatcher as dispatch
from pythonosc import osc_server
from pythonosc import udp_client
from pythonosc import osc_message_builder
from typing import List, Any
from collections import Counter

exclude = ["the", "and", "of", "or", "it", "at", "on", "in", "not", "be", "to", "we", "this", "that", "it's", "he", "she", "they", "them", "him", "her"]
needs_inventory = ["connection", "physicalwellbeing", "honesty", "play", "peace", "autonomy", "meaning"]

conn = pymysql.connect(host='localhost', user='researchasst', password='Root123!!',
                        database='clip_management2', charset='utf8mb4',
                        cursorclass=pymysql.cursors.DictCursor)

API_TOKEN = "?key=5c34c198-2db5-426c-9306-a8259ff5b7f2"
BASE_URL = "https://dictionaryapi.com/api/v3/references/thesaurus/json/"

class DictionaryWord:
    def __init__(self, word, fl, need, feel, rel_words):
        self.word = word
        self.fl = fl
        self.need = need
        self.feel = feel
        self.rel_words = rel_words

    def getStringForInsert(self):
        return "VALUES ('" + str(self.word) + "','" + str(self.fl) + "','" + str(self.need) + "','" + str(self.feel) + "')"

clientParser = argparse.ArgumentParser()
clientParser.add_argument("--ip",
    default="127.0.0.1", help="The ip to talk on")
clientParser.add_argument("--port",
    type=int, default=12103, help="The port to talk on")
argClient = clientParser.parse_args()

client = udp_client.UDPClient(argClient.ip, argClient.port)

def print_volume_handler(unused_addr, args, volume):
  print("[{0}] ~ {1}".format(args[0], volume))

def print_compute_handler(unused_addr, args, volume):
  try:
    print("[{0}] ~ {1}".format(args[0], args[1](volume)))
  except ValueError:
    pass

def getDictEntry(word):
    print("getDictEntry(" + word + ")")
    with conn.cursor() as cursor:
        stmt = "SELECT NEED, FEELING FROM DICTIONARY WHERE WORD = '" + word.lower() + "'"
        cursor.execute(stmt)
        result = cursor.fetchone()
        return result

def updateDatabase(dic_list):
    #check related words against needs inventory.
    #check list against feelings inventory.
    print("updateDatabase(" + str(len(dic_list)) + " entries)")
    for entry in dic_list:
        #print("\n\nmother word: " + entry.word)
        rel_needs = []
        rel_feelings = []
        baseSum = 0.0
        for w in entry.rel_words:
            baseSum += 1
            print("related word: " + w)
            with conn.cursor() as cursor:
                try:
                    stmt = "SELECT DISTINCT `NEED`, `FEELING` FROM DICTIONARY WHERE `WORD` = '" + w.lower() + "'"
                    cursor.execute(stmt)
                    result = cursor.fetchall()
                    if result is None:
                        #print("result is none")
                        try:
                            #select = "SELECT DISTINC WORD, NEED, FEELING FROM DICTIONARY WHERE WORD IN (SELECT DISTINCT MOTHER_WORD FROM RELATED_WORDS WHERE WORD = '" + w.lower() + "')"
                            select = "SELECT DISTINCT MOTHER_WORD FROM RELATED_WORDS WHERE WORD = '" + w.lower() + "'"
                            cursor.execute(select)
                            result = cursor.fetchone()
                            if result is None:
                                print("result is none")
                                try:
                                    stmt = "INSERT IGNORE INTO RELATED_WORDS (`WORD`, `MOTHER_WORD`) VALUES('"
                                    stmt += str(w).lower() + "','" + str(entry.word).lower() + "')"
                                    #print("insert statement: " + stmt)
                                    cursor.execute(stmt)
                                    conn.commit()
                                except Exception as e:
                                    print(e)
                            else:
                                sq = "SELECT DISTINC WORD, NEED, FEELING FROM DICTIONARY WHERE WORD = '" + result[0]["MOTHER_WORD"].lower() + "'"
                                cursor.execute(sq)
                                rs = cursor.fetchall()
                                for j in range(len(rs)):
                                    s = str(rs[0]["NEED"]).lower()
                                    rel_needs.append(s)
                                    s = str(rs[0]["FEELING"]).lower()
                                    rel_feelings.append(s)
                        except Exception as e:
                            print(e)
                    else:
                        if len(result) > 0:
                            for j in range(len(result)):
                                s = str(result[0]["NEED"]).lower()
                                rel_needs.append(s)
                                s = str(result[0]["FEELING"]).lower()
                                rel_feelings.append(s)
                except Exception as e:
                    print(e)

        pNeed = getPrimaryValue(rel_needs)
        if pNeed is None:
            pNeed = str(getPrimaryValue(needs_inventory))
            print("pNeed: " + pNeed)
            needs_inventory.append(pNeed)
        pFeel = getPrimaryValue(rel_feelings)
        if pFeel is None:
            with conn.cursor() as cursor:
                try:
                    sq = "SELECT COUNT(*), FEELING FROM DICTIONARY WHERE NEED = '" + pNeed + "' GROUP BY FEELING ORDER BY COUNT(*) ASC"
                    cursor.execute(sq)
                    rs = cursor.fetchone()
                    pFeel = str(rs["FEELING"])
                except Exception as e:
                    print(e)

        with conn.cursor() as cursor:
            try:
                stmt = "INSERT IGNORE INTO DICTIONARY (WORD, FL, NEED, FEELING) VALUES('"
                stmt += entry.word.lower() + "','" + entry.fl.lower() + "','" + pNeed + "','" + pFeel + "')"
                print(stmt)
                cursor.execute(stmt)
                conn.commit()
            except Exception as e:
                print(e)

def getPrimaryValue(listObj):
    if len(listObj) > 0:
        qt = Counter(listObj).most_common(1)
        return qt[0][0]
    else:
        return None

def get_words(address: str, *args: List[Any]):
    if not address == "/brain":
        print("not from brain")
        return
    #return if args length is 0 -- aka nothing was sent
    if not len(args):
        print("no args")
        return

    analysis = []
    new_entriesDic = []
    newWordsList = []
    for arg in args:
        print("N: " + arg)
        n = arg.replace("'", "")
        if n in exclude:
            print(n + " is in exclude list.")
            pass
        else:
            jsonObj = {}
            if if_word_exists(n) is True:
                print(n + "exists in dictionary DB")
                result = getDictEntry(n);
                if result is None:
                    fl = ""
                    jsonObj = call_dictionary(n)
                    try:
                        if(len(jsonObj[0]) > 0):
                            fl = jsonObj[0]["fl"]
                    except Exception as e:
                        print(e)

                    if fl == 'conjunction' or fl == 'pronoun' or fl == 'adverb':
                        #exclude.append(n)
                        #return None
                        pass
                    else:
                        newWordsList = handle_new_word(jsonObj)
                        if newWordsList is not None:
                            new_entriesDic.append(DictionaryWord(n, fl, "", "", newWordsList))
                else:
                    if len(result) > 0:
                        need = result["NEED"].lower()
                        feel = result["FEELING"].lower()

                        analysis.append(need)
            else:
                fl = ""
                jsonObj = call_dictionary(n)
                try:
                    if(len(jsonObj[0]) > 0):
                        fl = jsonObj[0]["fl"]
                except Exception as e:
                    print(e)
                else:
                    newWordsList = handle_new_word(jsonObj)
                if newWordsList is not None:
                    new_entriesDic.append(DictionaryWord(n, fl, "", "", newWordsList))

        msg = osc_message_builder.OscMessageBuilder(address = "/researchAssistant")
        a = Counter(analysis)
        for x in a:
            msg.add_arg(x)
            msg.add_arg(a[str(x)])
        msg = msg.build()
        print(a)
        client.send(msg)
        print(len(new_entriesDic))
        updateDatabase(new_entriesDic)

    return

def call_dictionary(word):
    print("adding new word: " + word)
    related_words = []
    r = requests.get(BASE_URL + word + API_TOKEN)
    return  r.json()

def handle_new_word(json0):
    related_words = []
    try:
        for i in range(len(json0[0]["meta"]["syns"])):
            for j in range(len(json0[0]["meta"]["syns"][i])):
                related_words.append(json0[0]["meta"]["syns"][i][j])
    except Exception as e:
        print(e)
        pass
    finally:
        pass
    ##########
    try:
        for i in range(len(json0[0]["def"][0]["sseq"])):
            for j in range(len(json0[0]["def"][0]["sseq"][i][0][1]["syn_list"][0])):
                related_words.append(json0[0]["def"][0]["sseq"][i][0][1]["syn_list"][0][j]["wd"])
    except Exception as e1:
        print("test")
        print(e1)
        try:
            for i in range(len(json0[0]["def"][0]["sseq"])):
                for j in range(len(json0[0]["def"][0]["sseq"][i][0][1]["sim_list"][0])):
                    related_words.append(json0[0]["def"][0]["sseq"][i][0][1]["sim_list"][0][j]["wd"])
        except Exception as e2:
            print(e2)
            pass
        finally:
            pass
    finally:
        pass
    #############
    try:
        for i in range(len(json0[0]["def"][0]["sseq"])):
            for j in range(len(json0[0]["def"][0]["sseq"][i][0][1]["rel_list"])):
                for z in range(len(json0[0]["def"][0]["sseq"][i][0][1]["rel_list"][j])):
                    related_words.append(json0[0]["def"][0]["sseq"][i][0][1]["rel_list"][j][z]["wd"])

    except Exception as e:
        print(e)
        pass
    finally:
        #print("list: ")
        #print(related_words)
        pass
    return related_words



def if_word_exists(word):
    with conn.cursor() as cursor:
        stmt = "SELECT DISTINCT COUNT(*) FROM DICTIONARY WHERE WORD = '" + word.lower() + "'"
        print(stmt)
        cursor.execute(stmt)
        result = cursor.fetchone()
        print(result)
        if result["COUNT(*)"] > 0:
            print("the word " + word + "exists in the DB")
            return True
        else:
            return False
    return False

if __name__ == "__main__":
    args = argparse.ArgumentParser()
    args.add_argument("--ip", default="127.0.0.1", help="The ip to listen on")
    args.add_argument("--port", type=int, default=12042, help="The port to listen on")
    listeningOn = args.parse_args()

    dispatcher = dispatch.Dispatcher()
    dispatcher.map("/brain", get_words)
    dispatcher.map("/volume", print_volume_handler, "Volume")
    dispatcher.map("/logvolume", print_compute_handler, "Log volume", math.log)

    server = osc_server.ThreadingOSCUDPServer((listeningOn.ip, listeningOn.port), dispatcher)
    server.serve_forever()
