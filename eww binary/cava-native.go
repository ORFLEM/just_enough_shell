package main

/*
#cgo pkg-config: fftw3 pulse
#include <stdlib.h>
#include <string.h>
#include <pulse/simple.h>
#include <pulse/error.h>
#include <fftw3.h>
#include <math.h>

// Параметры
#define BARS 20
#define SAMPLE_RATE 44100
#define BUFFER_SIZE 2048

typedef struct {
    pa_simple *pa;
    fftw_plan plan;
    double *in;
    fftw_complex *out;
    double bars[BARS];
} CavaContext;

CavaContext* cava_init() {
    CavaContext *ctx = malloc(sizeof(CavaContext));
    
    // PulseAudio
    pa_sample_spec ss = {
        .format = PA_SAMPLE_S16LE,
        .rate = SAMPLE_RATE,
        .channels = 2
    };
    
    int error;
    ctx->pa = pa_simple_new(NULL, "eww-cava", PA_STREAM_RECORD, NULL,
                            "audio visualizer", &ss, NULL, NULL, &error);
    
    if (!ctx->pa) {
        free(ctx);
        return NULL;
    }
    
    // FFTW
    ctx->in = fftw_malloc(sizeof(double) * BUFFER_SIZE);
    ctx->out = fftw_malloc(sizeof(fftw_complex) * (BUFFER_SIZE/2 + 1));
    ctx->plan = fftw_plan_dft_r2c_1d(BUFFER_SIZE, ctx->in, ctx->out, FFTW_ESTIMATE);
    
    memset(ctx->bars, 0, sizeof(ctx->bars));
    
    return ctx;
}

void cava_process(CavaContext *ctx) {
    int16_t buffer[BUFFER_SIZE * 2];
    int error;
    
    // Читаем аудио
    if (pa_simple_read(ctx->pa, buffer, sizeof(buffer), &error) < 0) {
        return;
    }
    
    // Конвертируем в double (mono)
    for (int i = 0; i < BUFFER_SIZE; i++) {
        ctx->in[i] = (buffer[i*2] + buffer[i*2+1]) / 65536.0;
    }
    
    // FFT
    fftw_execute(ctx->plan);
    
    // Распределяем по барам (логарифмическая шкала)
    int freq_per_bar = (BUFFER_SIZE / 2) / BARS;
    
    for (int i = 0; i < BARS; i++) {
        double sum = 0;
        int start = i * freq_per_bar;
        int end = (i + 1) * freq_per_bar;
        
        for (int j = start; j < end; j++) {
            double magnitude = sqrt(ctx->out[j][0] * ctx->out[j][0] + 
                                   ctx->out[j][1] * ctx->out[j][1]);
            sum += magnitude;
        }
        
        // Нормализация и сглаживание
        double val = (sum / freq_per_bar) * 10.0;
        ctx->bars[i] = ctx->bars[i] * 0.7 + val * 0.3;
        
        // Ограничиваем 0-7
        if (ctx->bars[i] > 7.0) ctx->bars[i] = 7.0;
        if (ctx->bars[i] < 0.0) ctx->bars[i] = 0.0;
    }
}

void cava_get_bars(CavaContext *ctx, int *output) {
    for (int i = 0; i < BARS; i++) {
        output[i] = (int)round(ctx->bars[i]);
    }
}

void cava_cleanup(CavaContext *ctx) {
    if (ctx->pa) pa_simple_free(ctx->pa);
    fftw_destroy_plan(ctx->plan);
    fftw_free(ctx->in);
    fftw_free(ctx->out);
    free(ctx);
}
*/
import "C"
import (
	"fmt"
	"strings"
	"time"
	"unsafe"
)

var blocks = []rune{'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}

func main() {
	ctx := C.cava_init()
	if ctx == nil {
		fmt.Fprintln(os.Stderr, "Failed to initialize cava")
		os.Exit(1)
	}
	defer C.cava_cleanup(ctx)

	ticker := time.NewTicker(16 * time.Millisecond) // ~60 FPS
	defer ticker.Stop()

	bars := make([]C.int, 20)
	lastOutput := ""
	var builder strings.Builder
	builder.Grow(20)

	for range ticker.C {
		C.cava_process(ctx)
		C.cava_get_bars(ctx, (*C.int)(unsafe.Pointer(&bars[0])))

		builder.Reset()
		for _, val := range bars {
			builder.WriteRune(blocks[int(val)])
		}

		result := builder.String()
		if result != lastOutput {
			fmt.Println(result)
			lastOutput = result
		}
	}
}
