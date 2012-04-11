int rectSize = 2;
int[][] space;
int[][] nextSpace;
ArrayList rules;

int[][] langLoop = {
  {0,2,2,2,2,2,2,2,2,0,0,0,0,0,0},
  {2,1,7,0,1,4,0,1,4,2,0,0,0,0,0},
  {2,0,2,2,2,2,2,2,0,2,0,0,0,0,0},
  {2,7,2,0,0,0,0,2,1,2,0,0,0,0,0},
  {2,1,2,0,0,0,0,2,1,2,0,0,0,0,0},
  {2,0,2,0,0,0,0,2,1,2,0,0,0,0,0},
  {2,7,2,0,0,0,0,2,1,2,0,0,0,0,0},
  {2,1,2,2,2,2,2,2,1,2,2,2,2,2,0},
  {2,0,7,1,0,7,1,0,7,1,1,1,1,1,2},
  {0,2,2,2,2,2,2,2,2,2,2,2,2,2,0}
};

void setup() {
  BufferedReader br;
  
  size(640, 480);
  colorMode(RGB, 100);
  int sizeX = width/rectSize;  // Number of rect for x and y axis
  int sizeY = height/rectSize;
  space = new int[sizeY][sizeX];
  nextSpace = new int[sizeY][sizeX];
  rules = new ArrayList();
  br = createReader("Langtons-Loops.table");
  
  // init space with -1
  for(int i=0; i<space.length; i++) {
    for(int j=0; j<space[i].length; j++) {
      space[i][j] = 0;
    }
  }
  
  int offsetX = sizeX/2;
  int offsetY = sizeY/2;
  for(int i=0; i<langLoop.length; i++) {
    for(int j=0; j<langLoop[i].length; j++) {
      space[offsetY-langLoop.length/2+i][offsetX-langLoop.length/2+j] = langLoop[i][j];
    }
  }
  
  // road rules
  String l;
  try {
    while((l = br.readLine()) != null) {
      // String -> int[] => [Center, North, East, South, Weat, NextCenter]; は後で
      if(Character.isDigit(l.charAt(0))) rules.add(l);
    }
  } catch (IOException e) {
    e.printStackTrace();
  }
  println("Loaded " + rules.size() + " rules.");
  frameRate(60);
}

void draw() {
  // Update state
  // - Rule apply
  updateState();
  // Draw state
  for(int i=0; i<space.length; i++) {
    for(int j=0; j<space[i].length; j++) {
      fill(stateToColor(space[i][j]));
      rect(j*rectSize, i*rectSize, rectSize, rectSize);
    }
  }
}

color stateToColor(int state) {
  return 100*state/7;
}

// ４近傍を読み込む
// ルールを適用する
//   ４近傍の値とルールの値を比べる
//   一致しなければルールを回転させ比べる
//   ↑を４回繰り返す

// n_states:8
// neighborhood:vonNeumann
// symmetries:rotate4
void updateState() {
  for(int i=1; i<space.length-1; i++) {
    for(int j=1; j<space[i].length-1; j++) {
      // 読み込み
      int vN[] = new int[5];
      // space[i][j] -> getvN -> vN[4]
      vN[0] = space[i][j];// Center
      vN[1] = space[i-1][j];// North 1 -> 2 -> 3 -> 4
      vN[2] = space[i][j+1];// East  2 -> 3 -> 4 -> 1
      vN[3] = space[i+1][j];// South 3 -> 4 -> 1 -> 2
      vN[4] = space[i][j-1];// Weat  4 -> 1 -> 2 -> 3
      
      // 比較
      String rule;
      int next = space[i][j];
      for(int k=0; k<rules.size(); k++) {
        rule = (String)rules.get(k);
        if (vN[0] == rule.charAt(0)-'0' && vN[1] == rule.charAt(1)-'0' &&
            vN[2] == rule.charAt(2)-'0' && vN[3] == rule.charAt(3)-'0' && vN[4] == rule.charAt(4)-'0') {
          next = rule.charAt(5)-'0';
          break;
        } else if (vN[0] == rule.charAt(0)-'0' && vN[1] == rule.charAt(2)-'0' &&
            vN[2] == rule.charAt(3)-'0' && vN[3] == rule.charAt(4)-'0' && vN[4] == rule.charAt(1)-'0') {
          next = rule.charAt(5)-'0';
          break;
        } else if (vN[0] == rule.charAt(0)-'0' && vN[1] == rule.charAt(3)-'0' &&
            vN[2] == rule.charAt(4)-'0' && vN[3] == rule.charAt(1)-'0' && vN[4] == rule.charAt(2)-'0') {
          next = rule.charAt(5)-'0';
          break;
        } else if (vN[0] == rule.charAt(0)-'0' && vN[1] == rule.charAt(4)-'0' &&
            vN[2] == rule.charAt(1)-'0' && vN[3] == rule.charAt(2)-'0' && vN[4] == rule.charAt(3)-'0') {
          next = rule.charAt(5)-'0';
          break;
        }
      }
      
      // 更新
      nextSpace[i][j] = next;
    }
  }
  // 全更新
  for(int i=0; i<space.length; i++) {
    for(int j=0; j<space[i].length; j++) {
      space[i][j] = nextSpace[i][j];
    }
  }
}
