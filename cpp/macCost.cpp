#include <bits/stdc++.h>
#include <iostream>

using namespace std;

int macCost(vector<int> cost, vector<string> labels, int dailyCount) {
    int cnt_total = cost.size();
    int cost_max = 0, cost_daily = 0;
    int cnt_legal = 0;
    for (int i = 0; i < cnt_total; i++)
    {
        cost_daily += cost[i];
        if (labels[i] == "legal") {
            cnt_legal++;
        }
        if (cnt_legal >= dailyCount) {
            cost_max = cost_max > cost_daily ? cost_max : cost_daily;
            cnt_legal = 0;
            cost_daily = 0;
        }
    }
    return cost_max;
}
int test_1 ()
{
    int cost_1[] = {2,5,3,11,1};
    string labels_1[] = {
        "legal",
        "illegal",
        "legal",
        "illegal",
        "legal",
    };
    vector<int> cost(5);
    vector<string> labels(5);
    for (int i = 0; i < 5; i++)
    {
        cost[i] = cost_1[i];
        labels[i] = labels_1[i];
    }
    int rtn_1 = macCost(cost, labels, 2);
    printf("out: %d\n\n", rtn_1);
    return 0;
}


int main(int argc, char *argv[])
{
    printf("Hello");
    test_1();
    return 0;
}