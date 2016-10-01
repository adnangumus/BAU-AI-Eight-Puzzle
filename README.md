# BAU-AI-Eight-Puzzle
Comparison of Uninformed and Informed  AI Algorithms for 8 Puzzle Solution

Discussion
Analysis of individual algorithms
Breadth-First Search
	      	Expands the shallowest nodes first; it is complete, optimal for unit step costs, but has exponential space complexity. The maximum size of the space complexity shows an exponential increase with the depth of the solution. Adding child nodes at each depth increases the space complexity also time complexity has a similar trend.

Uniform-Cost Search
		Expands the node with lowest path cost, g(n), and is optimal for general step costs. 
Depth-First Search
		Expands the deepest unexpanded node first. It is neither complete nor optimal, but has linear space complexity.  In most cases DFS finds the solution with much more
Figure. 3. Depth First Search Tree movements than say BFS, showing it is non-optimal. the DFS solution wanders down wrong paths, thus increasing time complexity.
Iterative Deepening Search
		Calls depth-first search with increasing depth limits until a goal is found. It is complete, optimal for unit step costs, has time complexity comparable to breadth-first search, and has linear space complexity. Since IDS iteratively increases depth for DFS, we get the optimal depth for the solution. However, at a depth n, IDS will have visited all the nodes in the trees at depth 0 to n-1 (= b^n nodes). BFS at depth n will only have visited b^n-1 nodes. Thus time complexity is greater for IDS compared to BFS and increases exponentially with depth. However, IDS has a better space complexity than DFS because the depth up to which a wrong path may be traversed is limited, thereby the number of unwanted child nodes is reduced.
Greedy Best-First Search
		Expands nodes with minimal h(n). It is not optimal but is often efficient. Greedy only considers the cost from current node to goal at every stage, not the cost up to the current node. This discounts cases where for 2 nodes A and B, A->Goal may have a better estimated cost than B, but B is at a lower depth, giving B a better total path cost. Actual space complexity may be affected by quality of the heuristic, as the search would take a path towards a more optimal solution, thus reducing child nodes in the node list.
A Star Search
		Expands nodes with minimal f (n) = g(n) + h(n). A∗ is complete and optimal, provided that h(n) is admissible (for  TREE-SEARCH) or consistent (for GRAPH-SEARCH). The space complexity of A∗ is still prohibitive. The cost function in A* estimates the full cost from root to goal on a particular path. This makes a better path as is evident in the number of movements in the solution. A* allows for "reversing" a decision, i.e., expanding the children of a different node than the current path, thus allowing for a more optimal solution. However, A* keeps a large list of unexplored children increasing the space complexity. Also, the case for a better heuristic still applies here.

Conclusions
 Search algorithms are judged on the basis of completeness, optimality, time complexity, and space complexity. Complexity depends on b, the branching factor in the state space, and d, the depth of the shallowest solution. 
The performance of heuristic search algorithms depends on the quality of the heuristic function. One can sometimes construct good heuristics by relaxing the problem definition, by storing precomputed solution costs for subproblems in a pattern database, or by learning from experience with the problem class. As we have seen in the studies of on the N Puzzle,the A* is seen to perform best, with its heuristics and faster convergence at cheaper cost and therefore conclude that the A* search is best suited for solving issues of this nature. In both cases, A* gave the best results and also has the possibilities to be applied towards issues of growing dimensionalities.
