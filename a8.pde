import java.util.List;
import java.util.ArrayList;

Cell[][] cells;

// TWEAKS ----------------------------
int cellSize = 20;
boolean fillWithRandomWalls = true;
float spawnWallChance = 0.3;
boolean showOnlyPath = false;
boolean canGoDiagonal = false;

List<Cell> openSet;
List<Cell> closedSet;

Cell start;
Cell goal;

List<Cell> path;

String state;
boolean switcher;

void setup() {
    size(800, 800);
    background(255);

    cells = new Cell[width / cellSize][height / cellSize];

    // create cells in grid
    for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
            cells[i][j] = new Cell(i, j);
        }
    }

    // find neighbors for each cell
    for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
            cells[i][j].findNeighbors(cells);
        }
    }

    closedSet = new ArrayList();
    openSet = new ArrayList();
    path = new ArrayList();

    start = cells[0][0];
    goal = cells[width / cellSize - 1][height / cellSize - 1];

    start.isWall = false;
    goal.isWall = false;

    openSet.add(start);

    drawCells();

    state = "drawing";
    switcher = true;
}

void draw() {
    if (state == "drawing") {
        if (mouseX > 0 && mouseY > 0 && mouseX < width && mouseY < height) {
            if (mousePressed && (mouseButton == LEFT)) {
                cells[mouseX / cellSize][mouseY / cellSize].isWall = true;
            } else if (mousePressed && (mouseButton == RIGHT)) {
                cells[mouseX / cellSize][mouseY / cellSize].isWall = false;
            }
        }

        drawCells();
        drawEndpoints();
    }

    if (state != "solving") return;
    if (openSet.size() > 0) {
        Cell x = getLowestFscoreCell(openSet);

        // set actual path
        Cell temp = x;
        path.clear();
        path.add(temp);
        while (temp.p != null) {
            path.add(temp.p);
            temp = temp.p;
        }

        // path found
        if (x.equals(goal)) {
            println("DONE! PATH LENGTH: " + path.size());
            noLoop();
        }

        closedSet.add(x);
        openSet.remove(x);

        for (Cell y : x.neighbors) {
            if (closedSet.contains(y) || y.isWall) {
                continue;
            }

            float tg = x.g + .1;
            boolean tBetter = false;

            if (!openSet.contains(y)) {
                openSet.add(y);
                y.h = dist(y.x, y.y, goal.x, goal.y);
                tBetter = true;
            } else if (tg < y.g) {
                tBetter = true;
            }

            if (tBetter == true) {
                y.p = x;
                y.g = tg;
                y.f = y.g + y.h;
            }
        }
    } else {
        println("NO SLUTION FOUND");
        noLoop();
    }

    if (showOnlyPath) drawCells();
    drawClosedSet();
    drawOpenSet();
    drawPath();
    drawEndpoints();
}


// DRAW FUNCTIONS -------------------------------------------------------------------
void drawEndpoints() {
    start.show(color(255, 195, 18));
    goal.show(color(237, 76, 103));
}

void drawOpenSet() {
    if (showOnlyPath) return;
    for (Cell c: openSet) {
        c.show(color(0, 255, 0));
    }
}

void drawClosedSet() {
    if (showOnlyPath) return;
    for (Cell c : closedSet) {
        c.show(color(234, 32, 39));
    }
}

void drawPath() {
    for (Cell c : path) {
        c.show(color(52, 152, 219));
    }
}

void drawCells() {
    for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
            cells[i][j].show(color(255));
        }
      }
}

// CELL CLASS -----------------------------------------------------------------------
class Cell {
    int x;
    int y;
    float f;
    float g;
    float h;
    List<Cell> neighbors;
    Cell p;
    boolean isWall;

    Cell(int x, int y) {
        this.x = x;
        this.y = y;
        this.neighbors = new ArrayList();

        if (fillWithRandomWalls) {
            this.isWall = random(1) < spawnWallChance;
        } else {
            isWall = false;
        }
    }

    void show(color c) {
        fill(c);
        if (isWall) {
            fill(0);
        }

        strokeWeight(1);
        rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }

    void findNeighbors(Cell[][] grid) {
        if (x < width / cellSize - 1) {
            neighbors.add(grid[x + 1][y]);
        }

        if (x > 0) {
            neighbors.add(grid[x - 1][y]);
        }

        if (y > 0) {
            neighbors.add(grid[x][y - 1]);
        }

        if (y < height / cellSize - 1) {
            neighbors.add(grid[x][y + 1]);
        }

        if (canGoDiagonal) {
            if (x < width / cellSize - 1 && y > 0) {
                neighbors.add(grid[x + 1][y - 1]);
            }
    
            if (x < width / cellSize - 1 && y < height / cellSize - 1) {
                neighbors.add(grid[x + 1][y + 1]);
            }
    
            if (x > 0 && y < height / cellSize - 1) {
                neighbors.add(grid[x - 1][y + 1]);
            }
    
            if (x > 0 && y > 0) {
                neighbors.add(grid[x - 1][y - 1]);
            }
        }
    }
}


// UTILS ------------------------------------------------------------------
Cell getLowestFscoreCell(List<Cell> cellList) {
    Cell lowest = cellList.get(0);

    for (int i = 1; i < cellList.size(); i++) {
        if (cellList.get(i).f < lowest.f) {
            lowest = cellList.get(i);
        }
    }

    return lowest;
}


// CONTROLS ---------------------------------------------------------------
void keyReleased() {
    if (keyCode == 32) {
    	state = "solving";
    }
}

void mousePressed() {
    if (mouseButton == CENTER) {
    	Cell temp = cells[mouseX / cellSize][mouseY / cellSize];

        if (switcher) {
            start = temp;
            start.isWall = false;
            openSet.clear();
            openSet.add(start);
        } else {
            goal = temp;
            goal.isWall = false;
        }

    	switcher = !switcher;
    }
}
