import tkinter as tk

class GameBoard(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.grid_buttons = []
        for i in range(4):
            row_buttons = []
            for j in range(23):
                button = tk.Button(self, text="", width=2, height=2, bg="blue",
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
        # Add game logic here (e.g., update the 2D array, check for win conditions)
        


root = tk.Tk()
board = GameBoard(root)
root.title("100 Hue Test")
root.mainloop()
