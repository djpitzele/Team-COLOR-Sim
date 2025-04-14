import tkinter as tk

# replace with real colors later
# 2D array with 4 rows and N_per_col entries per row (like real test)
N_per_col = 23
all_colors = [['#ff00ff' for x in range(N_per_col)] for x in range(4)]
all_colors[0][15] = '#0000ff'

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
        else:
            # check conditions for swap
            if self.last_row == row and 1 <= col <= N_per_col - 2:
                # make the swap
                # self.grid_buttons[row][col].grid(row=self.last_row, column=self.last_col)
                # self.grid_buttons[self.last_row][self.last_col].grid(row=row, column=col)
                # all_colors[row][col], all_colors[self.last_row][self.last_col] = all_colors[self.last_row][self.last_col], all_colors[row][col]
                print("swap them")
                # keep buttons in same place in the array, just swap colors using widget.configure(bg=value) (also swap colors in colors array?)
            self.reset_last_click()
        
    def reset_last_click(self):
        self.last_row = None
        self.last_col = None

root = tk.Tk()
board = GameBoard(root)
root.title("100 Hue Test")
root.mainloop()
