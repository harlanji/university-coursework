#include <stdio.h>
#include <math.h>


int max(int a, int b) {
    if(a > b) return a;
    else return b;
}


int min(int a, int b) {
    if(a < b) return a;
    else return b;
}



void calc_blocks(int maxb, int maxt, int w, int h) {
	int d = w + h;
	
	int nt, bh, bw, nd;
	
	nt = maxt;
	bw = ceil((double)w / (double)nt);
	bh = 10;
	nd = d / bh;
	
	if(w/bw > maxb) {
		printf("error: impossible configuration of max blocks/threads and the input.\n");
	}
	
	printf("nt=%i, bw=%i, bh=%i, nd=%i\n", nt, bw, bh, nd);
	
	int r;
	for(r = 0; r < nd; r++) {
		int sx = max(r - h, 0);
		int fx = min(r, w - 1);
		
		int nb = max(1, fx - sx);
		
		printf("sx=%i, sf=%i, nb=%i, nb=%i\n", sx, fx, nb);
		
		// spawn with nt and nb
	
		int x; // get from bI * bO + tI
		for(x = sx; x <= fx; x++) {
			int y = x + r;
			x *= bw;
			y *= bh;
		
			printf("%i: [%i, %i]\n", r, y, x);
		}
	}
	
}


int test_calc(int maxb, int maxt, int w, int h) {
	if(maxt*maxb > w) {
		return -1;
	}
	
	int bw = maxt;
	int bh = 10;
	int nby = ceil( (double)h / (double)bh );
	int nbx = ceil( (double)w / (double)bw );
	int nd = nbx + nby - 1;
	
	int d;
	for(d = 0; d < nd; d++) {
		
	}
}


int main() {
	calc_blocks(5, 2, 60, 80);
}
