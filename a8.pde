import java.util.List;
import java.util.ArrayList;
import java.util.Comparator;


int cellSize = 50;
Cell[][] cells;

List<Cell> openSet;
List<Cell> closedSet;

Cell start;
Cell goal;

List<Cell> path;

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
  
  closedSet = new ArrayList();
  openSet = new ArrayList();
  path = new ArrayList();
  
  start = cells[0][0];
  goal = cells[width / cellSize - 1][height / cellSize - 1];
  
  openSet.add(start);
  start.g = 0;
 
  // find neighbors
  for (int i = 0; i < cells.length; i++) {
    for (int j = 0; j < cells[i].length; j++) {
      cells[i][j].findNeighbors(cells);
    }
  }
  
  // show cells in grid
  for (int i = 0; i < cells.length; i++) {
    for (int j = 0; j < cells[i].length; j++) {
      cells[i][j].show(color(255));
    }
  }
}


void draw() {  
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
       print("DONE!");
       noLoop();
     }
     
     closedSet.add(x);
     openSet.remove(x);
     
     for (Cell y : x.neighbors) {
       if (closedSet.contains(y)) {
         continue;
       }
       
       float tg = x.g + 1;
       boolean tBetter = false;
       
       if (!openSet.contains(y)) {
         openSet.add(y);
         y.h = (int) dist(y.x, y.y, goal.x, goal.y);
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
  }
  
  // draw clsoed set
  for (Cell c : closedSet) {
    c.show(color(255, 0, 0));
  }
  
  // draw open set
  for (Cell c: openSet) {
    c.show(color(0, 255, 0));
  }
  
  // draw path
  for (Cell c : path) {
    c.show(color(0, 0, 255));
  }
  
  // draw start and goal
  goal.show(color(255, 255, 0));
  start.show(color(255, 255, 0));
}


class Cell {
  int x;
  int y;
  float f;
  float g;
  float h;
  List<Cell> neighbors;
  Cell p;
  
  Cell(int x, int y) {
    this.x = x;
    this.y = y;
    this.neighbors = new ArrayList();
  }
  
  void show(color c) {
    fill(c);
    strokeWeight(1);
    rect(x * cellSize, y * cellSize, cellSize, cellSize);
  }
  
  void findNeighbors(Cell[][] grid) {
    if (x < width / cellSize - 1) {
      neighbors.add(cells[x + 1][y]);
    }
    
    if (x > 0) {
      neighbors.add(cells[x - 1][y]);
    }
    
    if (y > 0) {
      neighbors.add(cells[x][y - 1]);
    }
    
    if (y < height / cellSize - 1) {
      neighbors.add(cells[x][y + 1]);
    }
  }
}

Cell getLowestFscoreCell(List<Cell> cellList) {
  Cell lowest = cellList.get(0);
  
  for (int i = 1; i < cellList.size(); i++) {
    if (cellList.get(i).f < lowest.f) {
      lowest = cellList.get(i);
    }
  }
  
  return lowest;
}
