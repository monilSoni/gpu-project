#include <stdio.h>
#include <unistd.h>

#define DISPLAY_ON 1
#define DISPLAY_OFF 0

void setGrid(int *grid, int N) {
	// In future, this function will set
	// the grid to whatever we want it to be
	// maybe with a string argument

	int dummy_grid[10][10] = {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
							  {0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
							  {0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
							  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
							  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
							  {0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
							  {0, 0, 1, 1, 0, 0, 0, 0, 0, 0},
							  {0, 0, 0, 0, 0, 1, 0, 0, 0, 0},
							  {0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
							  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};

	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 10; j++) {
			grid[i*N + j] = dummy_grid[i][j];
		}
	}
}

void display(int *arr, int N) {

	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			arr[i*N + j] ? printf("* ") : printf(". ");
		}
		printf("\n");
	}
	printf("\n");
}

int setValue(int *grid, int x, int y, int N) {

	int aliveNeighbours = 0;
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			aliveNeighbours += grid[((x+i)*N) + (y+j)];
		}
	}
	aliveNeighbours -= grid[x*N + y];

	return aliveNeighbours == 3 || (aliveNeighbours == 2 && grid[x*N + y]);
}

void nextGen(int *grid, int *newgrid, int N) { 

    for (int i = 1; i < N - 1; i++) {
		for (int j = 1; j < N - 1; j++) {
			newgrid[i*N + j] = setValue(grid, i, j, N);
		}
	}

	for (int i = 1; i < N-1; i++) {
		for (int j = 1; j < N-1; j++) {
			grid[i*N + j] = newgrid[i*N + j];
		}
	}
}

float simulateSerial(int *grid, int N, int disp_var) {

	// calls the function nextGen for the new grid
	// Updates the grid, sleeps and then displays.
	// It does this for SIMULATE_TIME times,
	// and returns the total runtime

	int *newgrid;
	newgrid = (int *)malloc(N * N * sizeof(int *));

	if(disp_var) {
		display(grid, N);
	}

	float elapsed_time;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    nextGen(grid, newgrid, N);
    // usleep(100000);
    if(disp_var) {
        display(grid, N);
    }

	cudaEventRecord(stop);
    cudaDeviceSynchronize();
    cudaEventElapsedTime(&elapsed_time, start, stop);

	free(newgrid);
	return elapsed_time;
}

int main() {

	int N = 16384;

	int *grid;
	grid = (int *)malloc(N * N * sizeof(int ));
	
	memset(grid, 0, N * N * sizeof(int));
	
	setGrid(grid, N);
	// display(grid, N);

	float elapsed_time = simulateSerial(grid, N, DISPLAY_OFF);
	// display(grid, N);

	printf("%dx%d  %0.4f ms\n", N, N, elapsed_time);

	free(grid);

	return 0;
}
