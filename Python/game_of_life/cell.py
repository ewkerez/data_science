class Cell:
    def __init__(self, x, y):
        self.alive = False
        self.next_status = None
        self.x = x
        self.y = y

    def toggle_status(self):
        self.alive = not self.alive

    def count_alive_neigbhours(self, cells):
        """
        Counts alive neighbours.
        :param cells: list of cells available in grid
        :return: int
        """
        # @ TODO: add variable that will represent amount of live neighbours
        num_alive = 0
        # check Moore's neighbourhood (8 neighbours)
        # which are the cells that are horizontally,
        # vertically or diagonally adjacent
        # @ TODO: loop over neighbourhood
        # dwie listy współrzędnych, wykorzystamy w iteracji
        x_coordinates = [self.x - 1, self.x, self.x + 1]
        y_coordinates = [self.y - 1, self.y, self.y + 1]
        for x in x_coordinates:
            for y in y_coordinates:
                if self.x == x and self.y == y:
                    continue
                try:
                    if cells[x][y].alive:
                        num_alive += 1 # num_alive = num+alive +1
                except IndexError:
                    print('Brak sasiada o wspolrzednych x:{} y :{}'.format(x, y))
        # don't check ourself
        # @ TODO: check the state of a neighbour - if it's alive add it
        return num_alive

    def apply_conway_rules(self, cells):
        """
        Verify amount of alive neighbours against Conways rule.
        :param cells: list of cells available in grid
        :return: True or False (cell lives or dies)
        """
        # @ TODO: check Conway's rules
        # zwraca warosc logiczna T or F, sprawdzmay czy komorka umiera?
        alive_nieghbours = self.count_alive_neigbhours(cells) # self jest magicznie przekazywany zawsze,
        # self jest reprezentacja instancji danego obiektu
        if self.alive:
            return not(alive_nieghbours == 2 or alive_nieghbours == 3)
        else:
            return alive_nieghbours == 3 # komorka jest martwa