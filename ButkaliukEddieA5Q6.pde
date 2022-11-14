final int ROWS= 75, COLS=81;       //The number of rows and columns of squares
final int SQ_SIZE=10;              //The size of each square in pixels

final int MAX_LENGTH = ROWS*COLS;  //the biggest size the snake can be
int startingLength = 5;            //the length player start with
int currentLength = startingLength;//the current size of the snake
int snakeSpeed = 7;                //snake moves every snakeSpeed frames

int x[] = new int[MAX_LENGTH];     //Store the x coordinates of each point of the snake in grid units, not pixels
int y[] = new int[MAX_LENGTH];     //Store the y coordniates of each point of the snake in grid units, not pixels

int level = 1;

int BG_COL = #c2b280;              //sand colour
int SNK_COL = #5a8d03;             //green colour
int APL_COL = #ff0800;             //red colour

final int DOWN = 0, LEFT = 1, UP = 2, RIGHT = 3;     //for storing the direction of the snake in a more readable way
int currentDirection = DOWN;                         //stores the current direction of the snake

boolean gameOver = false;                            //track if the user lost

final int[] DIRECTIONS_X = {0, -1, 0, 1};            //X changes for down left up right
final int[] DIRECTIONS_Y = {1, 0, -1, 0};            //Y changes for down left up right

int aplX[] = new int[MAX_LENGTH];                    //the X coordinate of apples
int aplY[] = new int[MAX_LENGTH];                    //the Y coordinate of apples
int aplCount = 0;                                    //total appples on the screen
int startingApples = 5;                              //the number of apples to start with

int snakeGrowthRate = 5;                             //how many circles eating an apple adds
long time = 0;                                       //track the time the snake has been moving for

int growthLeft = 0;                                  //track how many circles are needed to be added to the snake

//growth constants
final int SPEED_SUBTRAHEND = 1;
final float START_LENGTH_MULTIPLIER = 1.05;
final float GROWTH_RATE_MULTIPLIER = 1.2;
final int STARTING_APPLES_ADDEND = 3;

void setup(){
  size(810,750); //MUST be COLS*SQ_SIZE,ROWS*SQ_SIZE
  background(BG_COL);
  
  //set text size now otherwise the game pauses when you do it later
  textSize(height/10);
  
  //set snake and apples
  resetSnake();
  resetApples();
  
}//setup

void draw()
{
  
  if(time%snakeSpeed == 0 && !gameOver)                                        //snake moves every snakeSpeed frames
  {
    background(BG_COL);                                                        //clear canvas from previous frame
    
    //check if apple was eaten
    int binOfEatenApple = searchArrays(aplX, aplY, aplCount, 0, x[0], y[0]);   
    if(binOfEatenApple != -1)
    {
      //if it was, delete it and grow snake
      deleteApple(binOfEatenApple);
      growthLeft += snakeGrowthRate;
    }
        
    drawCircles(aplX, aplY, aplCount, APL_COL);                               //draw apples
    drawCircles(x,y,currentLength,SNK_COL);                                   //draw snake
      
    moveSnake(DIRECTIONS_X[currentDirection], DIRECTIONS_Y[currentDirection]);//move for next frame
    if(detectCrash())                                                         //if next frame is a crash
      printGameOver();                                                        //print game over
  }
  
   time++;                                                                    //track time since start
}
void drawCircles(int[] x, int[] y, int n, int colour)
{
  /*/* draws the first n amount of circles at the nth locations from x and y arrays with given colour */
  
  fill(colour);                                    //set the colour
    for(int i = 0; i <n; i++)                      //go through each point in the snake
    {
      //calculate the points
      int posX = SQ_SIZE/2 + x[i]*SQ_SIZE;         
      int posY = SQ_SIZE/2 + y[i]*SQ_SIZE;
      
      //draw circle
      circle(posX, posY, SQ_SIZE);
    }
}

void fillArray(int[] a, int n, int  start, int delta)
{ 
  /*/* fills the array with n items, starting at element 0 = start. Each element is delta bigger than the previous 
       delta would be +/-1 or 0                                                                                       */

  a[0] = start;                        //the first point in the snake is it's starting location (grid units)
  for(int i = 1; i < n; i ++)          //go through eacg point up to the length n
    a[i] = a[i-1] + delta;             //the current point is the previous + delta
}

void resetSnake()
{
  /*/* Resets the snake back to veritcal position at the center of the canas */
  
  currentLength = startingLength;                                    //reset the current length to starting length
  currentDirection = DOWN;
  fillArray(x, currentLength, COLS/2, 0);
  fillArray(y, currentLength, 1,-1);
}

void moveSnake(int addX, int addY)
{
  /*/* Moves the snake by 0, +/- 1 each 
       This works by shifting all the value of each in the snake array by one, making each consequtive 
       element of the aray (circle of the snake) take up position of the previous one. 
       Only the head of the snake is changed, by adding passed values. 
       All other circels take up the position of the one that came before it        
       
       If the snake needs to grow, the last element is kept by increasing the size of the snake           */
       
  
  for(int i = currentLength-1; i >=0; i--)              //start at the last item and go to the very first (0th)
  {
    //the next item is is the same as current
    //when this reapeats all items get moved over by one
    //the tail gets disgarded because snakeLength does not chage
    x[i+1] = x[i];                                      
    y[i+1] = y[i];
  }
  
  //grow the snake if needed
  if(growthLeft > 0)
  {
    growthLeft --;
    currentLength++;
  }
  //move head
  x[0] += addX;
  y[0] += addY;
}

void keyPressed()
{
  /*/* Handles the steering of the snake */
  
  if(key == 'l' || key == 'L' || key == 'd' || key == 'D')
  {
    //turn clockwise 
    currentDirection = (currentDirection+1)%4;
  }
  else if(key == 'a' || key == 'A' || key == 'j' || key == 'J')
  {
    //turn counter clockwise
    currentDirection = (currentDirection-1+4)%4;
  }
}

int[] randomArray(int n, int max)
{
  /*/*   Create an array with length n. Each element can be 0 up to no including max */
  
  int array[] = new int[n];                 //declare and initialize an array
  
  for(int i = 0; i < n; i ++)               //populate it
    array[i] = (int)random(max);            //by generating random values up to not including max (0 can be picked, so even though it does not go up to max, max values are possible)
    
  return array;
}

void resetApples()
{
  /*/* Generate new locations for apples. Amount is startingApples. Set aplCount to startingApples */
  
  aplX = randomArray(startingApples, COLS);
  aplY = randomArray(startingApples, ROWS);
  
  aplCount = startingApples;
}

int searchArrays(int [] x, int[] y, int n, int start, int keyX, int keyY)
{
  /*/* Search to see if the coordinate pair (keyX, keyY) is in some element ith element of x[] and y[].
       Search the first n elements. Start searching at start. 
       Return the index i where the pair is found. Return -1 if not found. */
       
  int returnValue = -1;                        //deafult return value
  boolean found = false;                       //track if the elements was found
  
  for(int i = start; i < n && !found; i++)     //stop searching if found
  {
    if(x[i] == keyX && y[i] == keyY)           //check if both x and y match
        {
          returnValue = i;                     //save the bin location where the matching pair is found
          found = true;                        //no need to keep searching
        }
  }
  
  return returnValue;
}

void deleteApple(int eatenApple)
{ 
  /*/* Delets the apple of bin number eatenApple. Shift all elements left. Reduce size by 1 */
  for(int i = eatenApple; i < aplCount-1; i++)
  {
    aplX[i] = aplX[i+1];
    aplY[i] = aplY[i+1];
  }
  aplCount --;
  
  if(aplCount == 0)
    newLevel();
}

boolean detectCrash()
{
  /*/* Checks if crashed into the wall or the snake */
  
   if(x[0] < 0 || x[0] >= COLS || y[0] < 0 || y[0] >= ROWS)                      //if x or y are outside canvas, snake crashed
     return true;
                                                                                 //check if crashed into snake
   if(searchArrays(x, y, currentLength, 1, x[0], y[0]) != -1)
     return true;
   
   //if got to this point, both if statmnets are falls, so we didnt crash
   return false;
}

void printGameOver()
{
/*/* Print "Game Over!" in the middle of the screen, and stop the game */

  gameOver = true;
  
  fill(0);
  String gmOvr = "Game Over!";
  int heightGmOvr = (int)(height+textAscent())/2;
  text(gmOvr, (width-textWidth(gmOvr))/2, heightGmOvr);
  
  
  //print results
  textSize(height/20);
  String currentLevel = "Level: " + level;
  String snakeLength = " Length: " + currentLength;
  String results = currentLevel + snakeLength;
  text(results, (width-textWidth(results))/2, heightGmOvr + textAscent() +5);
}

void newLevel()
{
  /*/* This updates all starting and growth values to start a new level
       Resets snake and apples */
       
  startingApples += STARTING_APPLES_ADDEND;
  if(snakeSpeed > 1)
    snakeSpeed -= SPEED_SUBTRAHEND;
  snakeGrowthRate *= GROWTH_RATE_MULTIPLIER;
  startingLength = (int)(currentLength * START_LENGTH_MULTIPLIER);
  
  level ++;
  
  resetSnake();
  resetApples();
}
