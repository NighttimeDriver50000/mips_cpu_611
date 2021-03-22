#include "Vdisplay_if_sdl.h"
#include "verilated.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_video.h>
#include <SDL2/SDL_render.h>
#include <SDL2/SDL_events.h>
#include <SDL2/SDL_keyboard.h>
#include <SDL2/SDL_keycode.h>

SDL_Window* window;
SDL_Renderer* renderer;
int pixel_size = 4;

extern "C" void sdl_write(int y, int x, int r, int g, int b) {
    SDL_Rect rect;
    rect.y = pixel_size * y;
    rect.x = pixel_size * x;
    rect.h = pixel_size;
    rect.w = pixel_size;
    //printf("RGB: 0x%02x%02x%02x\n", r, g, b);
    SDL_SetRenderDrawColor(renderer,
        (Uint8)r, (Uint8)g, (Uint8)b, SDL_ALPHA_OPAQUE);
    SDL_RenderFillRect(renderer, &rect);
    SDL_RenderPresent(renderer);
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vdisplay_if_sdl* top = new Vdisplay_if_sdl;
    top->clk = 0;
    top->mem_waddr = 0;
    top->mem_wdata = 0;
    top->mem_web = 0;
    bool done = false;

    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(128 * pixel_size, 64 * pixel_size, 0,
        &window, &renderer);

    while (!(Verilated::gotFinish() || done)) {
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();

        if (++top->mem_waddr >= 8192) {
            top->mem_waddr = 0;
        }
        uint32_t r = (top->mem_waddr >> 9) & 0x0f;
        uint32_t g = (top->mem_waddr >> 4) & 0x1f;
        uint32_t b = top->mem_waddr & 0x0f;
        top->mem_wdata = (r << 20) | (g << 11) | (b << 4);
        top->mem_web = 1;

        usleep(20);

        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_KEYDOWN:
                    if (event.key.keysym.sym == SDLK_q) {
                        done = true;
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
    top->final();
    delete top;
    exit(0);
}
