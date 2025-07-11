# NOTE: numpy and OpenCV required, run from python directory inside repo
import tkinter as tk
import csv
import numpy as np
import random
import cv2 as cv

# Settings
num_rows = 4
N_per_row = 10 # before duplication
shuffle = True
scale = 1.5

def shuffle(ac):
    # pass in all_colors, return version where rows are shuffled (excluding first and last elements)
    for i in range(num_rows):
        lcopy = ac[i][1:N_per_row - 1]
        random.shuffle(lcopy)
        ac[i][1:N_per_row - 1] = lcopy
    return ac

# read in colors
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

# duplicate end colors
for i in range(num_rows):
    all_colors[(i+1) % num_rows].insert(0, all_colors[i][-1])
N_per_row += 1

# shuffle if necessary
if shuffle:
    all_colors = shuffle(all_colors)

print(f"all colors: {all_colors}")

class GameBoard(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.last_row = None # row and col of last click
        self.last_col = None
        self.grid_buttons = []

        # create all buttons
        for i in range(num_rows):
            row_buttons = []
            for j in range(N_per_row):
                button = tk.Button(self, text="", width=int(6*scale), height=int(6*scale), bg=all_colors[i][j],
                                   command=lambda row=i, col=j: self.on_button_click(row, col))
                button.grid(row=i, column=j, pady=10)
                row_buttons.append(button)
            self.grid_buttons.append(row_buttons)

        # disable buttons at ends of rows
        for i in range(num_rows):
            self.grid_buttons[i][0].configure(state=tk.DISABLED)
            self.grid_buttons[i][N_per_row - 1].configure(state=tk.DISABLED)

        # make submit button and invisible one for spacing
        submit_button = tk.Button(self, text="Submit", width = int(18*scale), height = int(6*scale), bg = "green",
                                  command = lambda: self.on_button_click(exit()))
        submit_button.grid(row=num_rows, column=0)
        invis_button = tk.Button(self, text="", width = int(18*scale), height = int(6*scale), bg = "#f0f0f0", fg='#f0f0f0', borderwidth=0)
        invis_button.grid(row=num_rows, column=N_per_row-1)
        
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
