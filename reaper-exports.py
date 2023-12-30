from selenium import webdriver
from selenium.webdriver.common.by import By
import os
import shutil

activate_script = "/Users/briangildea/scripts/venv-reaper-export/bin/activate"
os.system(f"source {activate_script}")

dir = "/Users/briangildea/reaper-files/reaper-auto-export/"
files = os.listdir(dir)
filtered = [file for file in files if file.endswith("mp3")]
file_name = filtered[0]
file_path = os.path.join(dir, file_name)
abs_path = os.path.abspath(file_path)
print(files)
print(filtered)
print(file_name)
print(abs_path)

def run():
    try:
        options = webdriver.FirefoxOptions()
        options.add_argument('--headless')
        driver = webdriver.Firefox()
        driver.get("http://192.168.86.20/")
        driver.implicitly_wait(10)
        driver.find_element(By.ID, "fileupload").send_keys(abs_path)
        driver.implicitly_wait(10)
        shutil.copy(abs_path, "/Users/briangildea/Music/Music/Media.localized/0-sketches/")
        os.remove(abs_path) 
    except Exception as e:
        print(f"error: {e}")

run()
