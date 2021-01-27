import json
import os
import sys
import requests

BASE_URL = "https://api.telegram.org/bot{}".format(os.getenv('1695983718:AAH69SPrFrNbQciMPY6Rku_H0s7lhzZkVlI'))

def Main(req):
    try:
        data = json.loads(req.body.encode())
        message = str(data["message"]["text"])
        chat_id = data["message"]["chat"]["id"]
        first_name = data["message"]["chat"]["first_name"]

        response = "Please /start, {}".format(first_name)

        if "start" in message:
            response = "Hello {}! Type /help to get list of actions.".format(first_name)
            
        if "help" in message:
            response = (/about - узнать что умеет наш бот")
            
        if "about" in message:
            response = ("Наш бот поможет выбрать тебе фильм на вечер.")
            
        if "film" in message:
            response = ("Сегодня у тебя должен быть " random_film + " к просмотру")

        data = {"text": response.encode("utf8"), "chat_id": chat_id}
        url = BASE_URL + "/sendMessage"
        requests.post(url, data)

    except Exception as e:
        print(e)

    return {"statusCode": 200}, None
