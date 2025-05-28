import os

def press_enter_to_continue():
    print("Press Enter to continue...")
    input()

def directory(folder_path):
    file_names = os.listdir(folder_path)
    return file_names