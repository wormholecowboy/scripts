from selenium import webdriver
from selenium.webdriver.common import service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
import os

s = Service("/opt/homebrew/bin/chromedriver")

dir = "/Users/briangildea/scripts/"
files = os.listdir(dir)
file_name = files[2]
file_path = os.path.join(dir, file_name)
abs_path = os.path.abspath(file_path)


def run():
    try:
        print(file_path)
        print(abs_path)
        driver = webdriver.Firefox()
        driver.get("http://192.168.86.20/")
        driver.implicitly_wait(10)
        driver.find_element(By.ID, "fileupload").send_keys(abs_path)
    except Exception as e:
        print(f"error: {e}")

run()

