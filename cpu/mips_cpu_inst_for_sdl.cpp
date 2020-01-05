#include "Vmips_cpu_inst_for_sdl.h"
#include "Vmips_cpu_inst_for_sdl_mips_cpu_inst_for_sdl.h"
#include "Vmips_cpu_inst_for_sdl_mips_cpu.h"
#include "Vmips_cpu_inst_for_sdl_reg32x32.h"
#include "verilated.h"
#include <ncurses.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_video.h>
#include <SDL2/SDL_render.h>
#include <SDL2/SDL_events.h>
#include <SDL2/SDL_keyboard.h>
#include <SDL2/SDL_keycode.h>

SDL_Window* window;
SDL_Renderer* renderer;
int pixel_size = 4;

void sdl_write(int y, int x, int r, int g, int b) {
    SDL_Rect rect;
    rect.y = pixel_size * y;
    rect.x = pixel_size * x;
    rect.h = pixel_size;
    rect.w = pixel_size;
    SDL_SetRenderDrawColor(renderer,
        (Uint8)r, (Uint8)g, (Uint8)b, SDL_ALPHA_OPAQUE);
    SDL_RenderFillRect(renderer, &rect);
    SDL_RenderPresent(renderer);
}

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
    Vmips_cpu_inst_for_sdl* top = new Vmips_cpu_inst_for_sdl;
    top->CLOCK_50 = 0; // NOTE: downclocked from 50 MHz to 50 kHz
    top->KEY = 0b1110;
    top->SW = 0;
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

    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(128 * pixel_size, 64 * pixel_size, 0,
        &window, &renderer);

    while (!(Verilated::gotFinish() || done)) {
        top->eval();
        top->CLOCK_50 = ~(top->CLOCK_50);

        for (int i = 0; i < 8; ++i) {
            uint8_t segs = ~((top->HEX >> (i * 7)) & 0x7f);
            print7seg(0, i, segs);
        }
        mvprintw(5, 0, "0x%03x: 0x%08x", top->inst_addr, top->inst_word);
        for (int i = 1; i < 32; ++i) {
            int index = i;
            if (i == 30) {
                continue;
            } else if (i == 31) {
                index = 0;
            }
            uint32_t value
                = top->mips_cpu_inst_for_sdl->cpu->regs->registers[index];
            mvprintw(7 + (i % 16), 16 * (i / 16), "% 2d: 0x%08x", i, value);
        }

        //usleep(10);

        if (counter < 10) {
            if (++counter == 10) {
                top->KEY = 0b1111;
            }
            continue;
        }
 
        int c = getch();
        if (c == 'q') {
            done = true;
        }

        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_KEYDOWN:
                    switch (event.key.keysym.sym) {
                        case SDLK_q:
                            done = true;
                            break;
                        case SDLK_0:
                            top->KEY = top->KEY & 0b1110;
                            break;
                        case SDLK_1:
                            top->KEY = top->KEY & 0b1101;
                            break;
                        case SDLK_2:
                            top->KEY = top->KEY & 0b1011;
                            break;
                        case SDLK_3:
                            top->KEY = top->KEY & 0b0111;
                            break;
                    }
                    break;
                case SDL_KEYUP:
                    switch (event.key.keysym.sym) {
                        case SDLK_0:
                            top->KEY = top->KEY | 0b0001;
                            break;
                        case SDLK_1:
                            top->KEY = top->KEY | 0b0010;
                            break;
                        case SDLK_2:
                            top->KEY = top->KEY | 0b0100;
                            break;
                        case SDLK_3:
                            top->KEY = top->KEY | 0b1000;
                            break;
                    }
                    break;
                case SDL_QUIT:
                    done = true;
                    break;
                case SDL_WINDOWEVENT:
                    if (event.window.event == SDL_WINDOWEVENT_CLOSE) {
                        done = true;
                    }
                default:
                    break;
            }
        }

    }

    SDL_Quit();
    endwin();
    top->final();
    delete top;
    exit(0);
}
