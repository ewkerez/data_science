import tkinter as tk
from itertools import chain
from cell import Cell


class Window:
    def __init__(self, width=720, height=720, title='Game of life'):
        self.root = tk.Tk()
        self.size = (width, height)
        self.width, self.height = self.size
        self.root.title(title)
        self.game_id = None
        self.create_layout()
        self.init_buttons()
        self.bind_mouse_click()

    def create_layout(self):
        """
        Creates `<class 'tkinter.Frame'>` within window boundaries
        and `<class 'CanvasGrid'>` inside that frame. Canvas grid is used to
        display cell states in Game of Life.
        """
        self.frame = tk.Frame(self.root, width=self.width, height=self.height)
        self.frame.pack()
        self.canvas = CanvasGrid(self.frame, width=self.width,
                                 height=self.height)
        self.canvas.pack()

    def init_buttons(self):
        """
        Create and place buttons inside window.
        """
        start_button = tk.Button(self.root, text='Start', command=self.update)
        stop_button = tk.Button(self.root, text='Stop', command=self.stop)
        start_button.pack(side=tk.LEFT)
        stop_button.pack(side=tk.RIGHT)

    def bind_mouse_click(self, callback=None):
        """
        Use this method to specify callback for handling mouse clicks.
        :param callback: `<class 'function'>` if None is given then
                        it uses `<class 'CanvasGrid.change_colour_on_click'>`
        """
        if callback is None:
            callback = self.change_colour_on_click
        self.canvas.bind("<Button-1>", callback)

    def update(self):
        """
        Updates game screen.
        """
        self.canvas.update_cells()
        self.canvas.paint_grid()
        self.game_id = self.root.after(100, self.update)


    def stop(self):
        self.root.after_cancel(self.game_id)


    def change_colour_on_click(self, event, color='green'):
        """
        Changes colour of clicked element on `<class 'CanvasGrid'>`
        :param event: `<class 'tkinter.Event'>`
        :param color: str
        """
        self.canvas.change_colour(event, color)


class CanvasGrid(tk.Canvas):
    SIZE = 70
    START_X = 10
    START_Y = 10
    STEP = 10

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cells = []
        self.grid = []
        self.fill_grid()

    def update_cells(self):
        """
        Applies Conway rules for every cell in grid.
        """
        for cell in chain.from_iterable(self.cells):
            cell_dies = cell.apply_conway_rules(self.cells)
            if cell_dies:
                cell.next_status = not cell.alive
            else:
                cell.next_status = cell.alive

    @classmethod
    def find_rect_coordinates(cls, x, y):
        """
        Translates coordinates of click event to rectangle boundaries.
        :param x: int
        :param y: int
        :return: tuple(int, int)
        """
        x -= x % cls.START_X
        y -= y % cls.START_Y
        return x, y

    def fill_grid(self, color='white'):
        """
        Fills `<class 'tkinter.Canvas'>` with recangles that represent cells.
        :param color: str
        """
        x = CanvasGrid.START_X
        y = CanvasGrid.START_Y

        for row in range(CanvasGrid.SIZE):
            self.cells.append([])
            self.grid.append([])

            for column in range(CanvasGrid.SIZE):
                rect = self.create_rectangle(x, y, x + CanvasGrid.STEP,
                                             y + CanvasGrid.STEP, fill=color)
                self.grid[row].append(rect)
                self.cells[row].append(Cell(row, column))
                x += CanvasGrid.START_X

            x = CanvasGrid.START_X
            y += CanvasGrid.START_Y

    def change_colour(self, event, color):
        """
        Changes colour of a cell.
        :param event: `<class 'tkinter.Event'>`
        """
        x, y = CanvasGrid.find_rect_coordinates(event.x, event.y)
        try:
            iy = x // 10 - 1
            ix = y // 10 - 1
            if ix == -1 or iy == -1:
                raise IndexError
            if self.cells[ix][iy].alive:
                self.itemconfig(self.grid[ix][iy], fill='white')
            else:
                self.itemconfig(self.grid[ix][iy], fill=color)
            self.cells[ix][iy].toggle_status()
        except IndexError:
            return

    def paint_grid(self, alive_color='red'):
        """
        Color rectangles to specified color that mimics its state.
        """
        for cell in chain.from_iterable(self.cells):
            current_status = cell.alive
            if cell.next_status != current_status:
                if cell.next_status:
                    self.itemconfig(self.grid[cell.x][cell.y], fill=alive_color)
                else:
                    self.itemconfig(self.grid[cell.x][cell.y], fill='white')
                cell.alive = cell.next_status


if __name__ == '__main__':
    window = Window()
    window.root.mainloop()
