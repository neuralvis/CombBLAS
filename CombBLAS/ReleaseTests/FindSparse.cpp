#include <mpi.h>
#include <sys/time.h> 
#include <iostream>
#include <functional>
#include <algorithm>
#include <vector>
#include <sstream>
#include "../CombBLAS.h"

using namespace std;

template <typename PARMAT>
void Symmetricize(PARMAT & A)
{
	// boolean addition is practically a "logical or"
	// therefore this doesn't destruct any links
	PARMAT AT = A;
	AT.Transpose();
	A += AT;
}

int main(int argc, char* argv[])
{
	MPI::Init(argc, argv);
	int nprocs = MPI::COMM_WORLD.Get_size();
	int myrank = MPI::COMM_WORLD.Get_rank();

	if(argc < 3)
	{
		if(myrank == 0)
		{
			cout << "Usage: ./FindSparse <BASEADDRESS> <Matrix>" << endl;
			cout << "Input files should be under <BASEADDRESS> in appropriate format" << endl;
		}
		MPI::Finalize(); 
		return -1;
	}				
	{
		string directory(argv[1]);		
		string matrixname(argv[2]);
		matrixname = directory+"/"+matrixname;
	
		typedef SpParMat <int, double, SpDCCols<int,double> > PARDBMAT;
		PARDBMAT A;		// declare objects
		FullyDistVec<int,int> crow, ccol;
		FullyDistVec<int,double> cval;

		A.ReadDistribute(matrixname, 0);	

		A.Find(crow, ccol, cval);
		PARDBMAT B(A.getnrow(), A.getncol(), crow, ccol, cval); // Sparse()

		if (A ==  B)
		{
			SpParHelper::Print("Find and Sparse working correctly\n");	
		}
		else
		{
			SpParHelper::Print("ERROR in Find(), go fix it!\n");	

			SpParHelper::Print("Rows array: \n");
			crow.DebugPrint();

			SpParHelper::Print("Columns array: \n");
			ccol.DebugPrint();

			SpParHelper::Print("Values array: \n");
			cval.DebugPrint();
		}
		
		// Begin testing a Matlab like use case
		// Example provided by Arne De Coninck <arne.deconinck@ugent.be>
		// X = ones(size(A,2),1) 
		// M = [X' * X, X' * A; A'* X, A' * A]
		
		A.PrintInfo();
		Symmetricize(A);
		FullyDistVec<int,int> rowsym, colsym;
		FullyDistVec<int,double> valsym;
		A.Find(rowsym, colsym, valsym);
		
		FullyDistVec<int,double> colsums; 
		A.Reduce(colsums, Column, plus<double>(), 0.0);
		
		FullyDistVec<int,double> numcols(1, A.getncol());
		vector< FullyDistVec<int,double> > vals2concat{numcols, colsums, colsums, valsym};
		FullyDistVec<int,double> nval = Concatenate(vals2concat);
		nval.PrintInfo("Values:");
		
		// sparse() expects a zero based index		
		FullyDistVec<int,int> firstrowrids(A.getncol()+1, 0);	// M(1,:)
		FullyDistVec<int,int> firstcolrids(A.getncol(), 0);	// M(2:end,1)
		firstcolrids.iota(A.getncol(),1);	// fill M(2:end,1)'s row ids
		rowsym.Apply(bind2nd(plus<int>(), 1));
		
		vector< FullyDistVec<int,int> > rows2concat{firstrowrids, firstcolrids, rowsym};	// C++11 style
		FullyDistVec<int,int> nrow = Concatenate(rows2concat);
		nrow.PrintInfo("Row ids:");
		
		FullyDistVec<int,int> firstrowcids(A.getncol()+1, 0);	// M(1,:)
		firstrowcids.iota(A.getncol()+1,0);	// fill M(1,:)'s column ids
		FullyDistVec<int,int> firstcolcids(A.getncol(), 0);	// M(2:end,1)
		colsym.Apply(bind2nd(plus<int>(), 1));
		
		vector< FullyDistVec<int,int> > cols2concat{firstrowcids, firstcolcids, colsym}; // C++11 style
		FullyDistVec<int,int> ncol = Concatenate(cols2concat);
		ncol.PrintInfo("Column ids:");
		
		PARDBMAT M(A.getnrow()+1, A.getncol()+1, nrow, ncol, nval); // Sparse()
		M.PrintInfo();
		
		// End Arne's test case 
	}
	MPI::Finalize();
	return 0;
}
