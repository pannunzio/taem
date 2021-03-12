# SETUP FILE: READS WHATS IN THE CATALOG OF FEELINGS AND NEEDS, ADDS THEM TO THE DICTIONARY,
# THEN CHECKS FOR RELATED_WORDS TO FACILITATE SEARCHING.
# MORE WORDS IN DB == LESS API REQUESTS == SAVES TIME AND CPU
#
#  EXECUTE ONLY` ONCE TO POPULATE DB.


import json
import requests
import urllib.request
import urllib.parse
import pymysql

class relatedwords:
    def __init__(self, word, need, list):
        self.word = word
        self.need = need
        self.list = list

class wordentry:
    def __init__(self, word, fl, need, feel):
        self.word = word
        self.fl = fl
        self.need = need
        self.feel = feel

    def getAsString(self):
        return "VALUES ('" + str(self.word) + "','" + str(self.fl) + "','" + str(self.need) + "','" + str(self.feel) + "')"

conn = pymysql.connect(host='localhost', user='setup', password='Root123!!',
                        database='clip_management', charset='utf8mb4',
                        cursorclass=pymysql.cursors.DictCursor)

#Yes i am very aware of this major lapse in security.
#time is an issue. To Be Fixed.
API_TOKEN = "?key=5c34c198-2db5-426c-9306-a8259ff5b7f2"
BASE_URL = "https://dictionaryapi.com/api/v3/references/thesaurus/json/"

def getRelatedWords(n):
    list = []
    r = requests.get(BASE_URL + n + API_TOKEN)
    deff = r.json()
    if not deff:
        return []
    else:
        if not deff:
            return []

        else:
            try:
                for i in range(len(deff[0]["meta"]["stems"])):
                    list.append(deff[0]["meta"]["stems"][i])
            except Exception as e:
                print(e)
                return list

            try:
                for i in range(len(deff[0]["meta"]["syns"])):
                    for j in range(len(deff[0]["meta"]["syns"][i])):
                        list.append(deff[0]["meta"]["syns"][i][j])
            except Exception as e:
                print(e)
                return list

            try:
                for i in range(len(deff[0]["def"][0]["sseq"])):
                    for j in range(len(deff[0]["def"][0]["sseq"][i][0][1]["syn_list"][0])):
                        list.append(deff[0]["def"][0]["sseq"][i][0][1]["syn_list"][0][j]["wd"])
                    for j in range(len(deff[0]["def"][0]["sseq"][i][0][1]["rel_list"])):
                        for z in range(len(deff[0]["def"][0]["sseq"][i][0][1]["rel_list"][j])):
                            list.append(deff[0]["def"][0]["sseq"][i][0][1]["rel_list"][j][z]["wd"])

            except Exception as e:
                print(e)
                return list

        print("\n\n" + str(list))
        return list
    return ""

def getFL(n):
    try:
        r = requests.get(BASE_URL+ n + API_TOKEN)
        jj = r.json()
        if not jj[0]:
            return " "
        else:
            if(len(jj[0]) > 0):
                str = jj[0]["fl"]
                return str
            else:
                return " "
    except Exception as e:
        print(e)
        return " "

if __name__ == "__main__":
    newEntries = []

    with conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT WORD, FEELING, PRIMARY_NEED FROM FEELINGS_CATALOG")
            result = cursor.fetchall()
            for row in result:
                fl = getFL(row["WORD"])
                print("word: " + row["WORD"] + ", f.l.: " + fl)
                newEntries.append(wordentry(row["WORD"], fl, row["PRIMARY_NEED"], row["FEELING"]))

            print("\n\ndic size so far: " + str(len(newEntries)))

            cursor.execute("SELECT WORD, MET, NEED FROM NEEDS_CATALOG")
            result = cursor.fetchall()
            for row in result:
                fl = getFL(row["WORD"])
                print("word: " + row["WORD"] + ", f.l.: " + fl)
                newEntries.append(wordentry(row["WORD"], fl, row["NEED"], row["MET"]))

            print("dic size so far: " + str(len(newEntries)))

            for e in newEntries:
                stmt = "INSERT INTO DICTIONARY (`WORD`, `FL`, `NEED`, `FEELING`) " + e.getAsString()
                cursor.execute(stmt)
                conn.commit()

            relWords = []
            cursor.execute("SELECT WORD, NEED FROM DICTIONARY")
            result = cursor.fetchall()
            for row in result:
                list = getRelatedWords(row["WORD"])
                relWords.append(relatedwords(row["WORD"], row["NEED"], list))

            for w in relWords:
                l = w.list
                for i in range(len(l)):
                    stmt = "INSERT INTO RELATED_WORDS (`WORD`, `MOTHER_WORD`) "
                    stmt += "VALUES ('" + str(l[i]) + "','" + str(w.word) + "')"
                    try:
                        cursor.execute(stmt)
                    except Exception as e:
                        pass
                    finally:
                        conn.commit()
