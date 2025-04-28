# NOTE: numpy and OpenCV required, run from python directory inside repo

import tkinter as tk
import csv
import numpy as np
import cv2 as cv

def rgb_to_hex(arr):
    return "#{:02X}{:02X}{:02X}".format(arr[0], arr[1], arr[2])

N_per_col = 23
all_colors_LUV = []
with open('../data_tables/fm100_colors_fixed.csv', 'r') as file:
    csvreader = csv.reader(file)
    _header = next(csvreader)
    for row in csvreader:
        all_colors_LUV.append(list(map(float, row))[1:])
all_colors_LUV = np.expand_dims(np.array(all_colors_LUV), 1).astype('float32')
# all_colors_orig = [['#ff00ff' for x in range(N_per_col)] for x in range(4)]
# all_colors_orig[0][15] = '#0000ff'
# 2D array with 4 rows and N_per_col entries per row (like real test)
all_colors_rgb = (np.squeeze(cv.cvtColor(all_colors_LUV, cv.COLOR_Luv2RGB)) * 255).astype(int)
all_colors_orig = ['' for x in range(len(all_colors_rgb))]
for i in range(len(all_colors_rgb)):
    all_colors_orig[i] = rgb_to_hex(all_colors_rgb[i])
all_colors = all_colors_orig.copy()

class GameBoard(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.last_row = None # row and col of last click
        self.last_col = None
        self.grid_buttons = []
        for i in range(4):
            row_buttons = []
            for j in range(N_per_col):
                button = tk.Button(self, text="", width=2, height=2, bg=all_colors[i][j],
                                   command=lambda row=i, col=j: self.on_button_click(row, col))
                button.grid(row=i, column=j)
                row_buttons.append(button)
            self.grid_buttons.append(row_buttons)
        submit_button = tk.Button(self, text="Submit", width = 6, height = 2, bg = "green",
                                  command = lambda: self.on_button_click(exit()))
        submit_button.grid(row=4, column=0)
        
        self.pack()

    def on_button_click(self, row, col):
        # Handle button click event
        print(f"Button clicked at row: {row}, column: {col}")
        if self.last_row is None and self.last_col is None:
            self.last_row = row
            self.last_col = col
            self.grid_buttons[row][col].configure(relief="groove")
        else:
            # check conditions for swap
            if self.last_row == row and 1 <= col <= N_per_col - 2:
                # make the swap
                print("swap them")
                all_colors[row][col], all_colors[self.last_row][self.last_col] = all_colors[self.last_row][self.last_col], all_colors[row][col]
                self.grid_buttons[row][col].configure(bg=all_colors[row][col])
                self.grid_buttons[self.last_row][self.last_col].configure(bg=all_colors[self.last_row][self.last_col])
            self.reset_last_click()
        
    def reset_last_click(self):
        self.grid_buttons[self.last_row][self.last_col].configure(relief="raised")
        self.last_row = None
        self.last_col = None

root = tk.Tk()
board = GameBoard(root)
root.title("100 Hue Test")
root.mainloop()
