# NOTE: numpy and OpenCV required, run from python directory inside repo

# TODO: remove visual (and effect?) of pressing the buttons at end of the row

import tkinter as tk
import csv
import numpy as np
import cv2 as cv

num_rows = 1
N_per_row = 40
all_colors = []
with open('../data_tables/munsell_hex_40.csv', 'r') as file:
    csvreader = csv.reader(file)
    _header = next(csvreader)
    i = 0
    for row in csvreader:
        if i % N_per_row == 0:
            all_colors.append([])
        all_colors[-1].append(row[0].strip())
        i += 1
print(f"all colors: {all_colors}")

class GameBoard(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.last_row = None # row and col of last click
        self.last_col = None
        self.grid_buttons = []
        for i in range(num_rows):
            row_buttons = []
            for j in range(N_per_row):
                button = tk.Button(self, text="", width=2, height=2, bg=all_colors[i][j],
                                   command=lambda row=i, col=j: self.on_button_click(row, col))
                button.grid(row=i, column=j)
                row_buttons.append(button)
            self.grid_buttons.append(row_buttons)
        # self.grid_buttons[0][0].configure(relief=tk.FLAT) (see chat for how to disable)
        submit_button = tk.Button(self, text="Submit", width = 6, height = 2, bg = "green",
                                  command = lambda: self.on_button_click(exit()))
        submit_button.grid(row=num_rows, column=0)
        
        self.pack()

    def on_button_click(self, row, col):
        # Handle button click event
        print(f"Button clicked at row: {row}, column: {col}")
        if 1 <= col <= N_per_row - 2:
            if self.last_row is None and self.last_col is None:
                self.last_row = row
                self.last_col = col
                self.grid_buttons[row][col].configure(relief="groove")
            else:
                # check conditions for swap
                if self.last_row == row:
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
