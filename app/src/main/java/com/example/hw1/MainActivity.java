package com.example.hw1;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import androidx.appcompat.app.AppCompatActivity;


import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity {

    //define variables
    private ImageView right;
    private ImageView left;
    private LinearLayout man_layout;
    private TableLayout mat_layout;
    private int position;
    private int eaten;
    private int index;

    private Timer timer;

    private final int ROWS = 7;
    private final int COLS = 3;
    private final int FALL_SPEED = 300;
    private final int HEARTS_SIZE = 3;
    private final ImageView[] hearts = new ImageView[HEARTS_SIZE];
    private final int RATE = COLS;
    private final int MAX_NUM = 3;
    private final int MIN_NUM = 1;
    private Random random;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initializeVars();
        FindViews();
        leftOnClickListener();
        rightOnClickListener();
        hamburgersDrops();
    }

    private void timerActivate() {
        this.runOnUiThread(() -> {


            if (index % RATE == 0)
                showHamburger(0,hamPositions());
            index++;

            //update hearts
            eatenValidation();
            PositionsHamUpdate();

        });
    }

    private void hamburgersDrops() {
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                timerActivate();
            }

        }, 0, FALL_SPEED);
    }

    private void PositionsHamUpdate() {
        for (int i = index % RATE; i < mat_layout.getChildCount(); i += RATE) {
            TableRow row = (TableRow) mat_layout.getChildAt(i);
            for (int j = 0; j < row.getChildCount(); j++) {
                ImageView ham = (ImageView) row.getChildAt(j);

                //check visible
                if (ham.getVisibility() == View.VISIBLE) {
                    ham.setVisibility(View.INVISIBLE);
                    if (i + 1 < mat_layout.getChildCount())
                        showHamburger(i + 1, j);
                }
            }
        }
        for (int i =mat_layout.getChildCount(); i <  index % RATE; i -= RATE) {
            TableRow row = (TableRow) mat_layout.getChildAt(i);
            for (int j = 0; j < row.getChildCount(); j++) {
                ImageView ham = (ImageView) row.getChildAt(j);

                //check visible
                if (ham.getVisibility() == View.VISIBLE) {
                    ham.setVisibility(View.INVISIBLE);
                    if (i + 1 < mat_layout.getChildCount())
                        showHamburger(i + 1, j);
                }
            }
        }
    }


    public int hamPositions() {
        return random.nextInt(COLS);
    }

    private void eatenValidation() {

        TableRow row = (TableRow) mat_layout.getChildAt(ROWS - 2);

        for (int i = 0; i < row.getChildCount(); i++) {
            ImageView obj = (ImageView) row.getChildAt(i);

            // eat
            if (obj.getVisibility() == View.VISIBLE && position == i +1) {
                eaten += 1;

                if (eaten > HEARTS_SIZE) {
                    gameOver();
                } else
                    hearts[HEARTS_SIZE - eaten].setVisibility(View.INVISIBLE);
            }
        }

    }

    private void gameOver() {

        hearts[0].setVisibility(View.INVISIBLE);
        Intent switchActivityIntent = new Intent(this, GameOverActivity.class);
        startActivity(switchActivityIntent);
        timer.cancel();
    }


    private void showHamburger(int index1, int index2) {
        TableRow row = (TableRow) mat_layout.getChildAt(index1);
        ImageView img_ham = (ImageView) row.getChildAt(index2);
        img_ham.setVisibility(View.VISIBLE);
    }

    private void FindViews() {

        right = (ImageView) findViewById(R.id.main_IMG_right);
        left = (ImageView) findViewById(R.id.main_IMG_left);
        man_layout = (LinearLayout) findViewById(R.id.main_IMG_man);
        mat_layout = findViewById(R.id.main_IMG_mat);

        hearts[0] = findViewById(R.id.main_IMG_first_heart);
        hearts[1] = findViewById(R.id.main_IMG_second_heart);
        hearts[2] = findViewById(R.id.main_IMG_third_heart);



    }
    private void initializeVars() {
        random = new Random();
        index = 0;
        position = 2;
        eaten = 0;
    }
    private void leftOnClickListener() {
        left.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                if (position > MIN_NUM) {
                    MoveLeft();
                }
            }
        });

    }
    private void rightOnClickListener() {
        right.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (position < MAX_NUM) {
                    MoveRight();
                }
            }
        });

    }

    private void MoveRight() {
        position++;
        updatePosition();
    }


    private void MoveLeft() {
        position--;
        updatePosition();
    }


    private void updatePosition() {
        for (int i = 0; i < man_layout.getChildCount(); i++) {
            ImageView man = (ImageView) man_layout.getChildAt(i);
            man.setVisibility(View.INVISIBLE);
        }

        //update position of the man
        ((ImageView) man_layout.getChildAt(position - 1)).setVisibility(View.VISIBLE);
    }

}
