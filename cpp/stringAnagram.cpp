#include <bits/stdc++.h>
#include <iostream>

using namespace std;

struct htg
{
    int a_z[26];
};

vector<int> stringAnagram(vector<string> dictionary, vector<string> query)
{
    int n_dic = dictionary.size();
    vector<struct htg> htg_2(n_dic);
    for (int j = 0; j < n_dic; j++)
    {
        string str_2 = dictionary[j];
        struct htg htg_t = {};
        for (int k = 0; k < str_2.length(); k++)
        {
            int idx = str_2[k] - 'a';
            htg_t.a_z[idx]++;
        }
        htg_2[j] = {htg_t};
    }
    int n_qry = query.size();
    vector<int> rtn(n_qry);
    for (int i = 0; i < n_qry; i++)
    {
        string str_1 = query[i];
        int htg_1[26] = {};
        for (int k = 0; k < str_1.length(); k++)
        {
            int idx = str_1[k] - 'a';
            htg_1[idx]++;
        }
        for (int j = 0; j < n_dic; j++)
        {
            bool mch = true;
            for (int k = 0; k < 26; k++)
            {
                mch = htg_1[k] == htg_2[j].a_z[k];
                if (!mch)
                    break;
            }
            if (mch)
                rtn[i]++;
        }
    }
    return rtn;
}
int test_1()
{
    string str_1[] = {"heater", "cold", "clod", "reheat", "docl"};
    string str_2[] = {"codl", "heater", "abcd"};
    vector<string> dictionary(5);
    vector<string> query(3);
    for (int i = 0; i < 5; i++)
    {
        dictionary[i] = str_1[i];
    }
    for (int i = 0; i < 3; i++)
    {
        query[i] = str_2[i];
    }
    vector<int> rtn_1 = stringAnagram(dictionary, query);
    for (int i = 0; i < rtn_1.size(); i++)
    {
        printf("Out: %d\n", rtn_1[i]);
    }
    return 0;
}

int main(int argc, char *argv[])
{
    printf("Hello");
    test_1();
    return 0;
}