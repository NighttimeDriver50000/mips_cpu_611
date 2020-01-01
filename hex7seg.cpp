#include "Vhex7seg.h"
#include "verilated.h"
#include <ncurses.h>

void print7seg(int row, int col, uint8_t segs) {
    int base_y = row * 4;
    int base_x = col * 4;
    for (int y = base_y; y < base_y + 4; ++y) {
        mvprintw(y, base_x, "    ");
    }
    if (segs & 0x01) { mvaddch(base_y + 0, base_x + 1, '_'); }
    if (segs & 0x02) { mvaddch(base_y + 1, base_x + 2, ':'); }
    if (segs & 0x04) { mvaddch(base_y + 2, base_x + 2, ':'); }
    if (segs & 0x08) { mvaddch(base_y + 2, base_x + 1, '_'); }
    if (segs & 0x10) { mvaddch(base_y + 2, base_x + 0, ':'); }
    if (segs & 0x20) { mvaddch(base_y + 1, base_x + 0, ':'); }
    if (segs & 0x40) { mvaddch(base_y + 1, base_x + 1, '_'); }
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vhex7seg* top = new Vhex7seg;
    top->clk = 0;
    top->reset = 0;
    top->value = 0;
    int counter = 0;
    bool done = false;

    initscr();
    cbreak();
    noecho();
    nonl();
    intrflush(stdscr, TRUE);
    keypad(stdscr, TRUE);
    nodelay(stdscr, TRUE);
    curs_set(0);

    while (!(Verilated::gotFinish() || done)) {
        top->eval();
        print7seg(0, 0, ~(top->segs));
        top->clk = ~top->clk;
        if (counter < 20) {
            ++counter;
            if (counter == 10) {
                top->reset = 1;
            } else if (counter == 20) {
                top->reset = 0;
            }
        } else {
            int c = getch();
            if (c == 'n') {
                if (top->value < 0xF) {
                    ++(top->value);
                } else {
                    top->value = 0;
                }
            } else if (c == 'q') {
                done = true;
            }
        }
        usleep(10000);
    }

    endwin();
    top->final();
    delete top;
    exit(0);
}
