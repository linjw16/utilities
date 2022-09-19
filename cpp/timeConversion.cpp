#include <bits/stdc++.h>

using namespace std;

/*
 * Complete the 'timeConversion' function below.
 *
 * The function is expected to return a STRING.
 * The function accepts STRING s as parameter.
 */

string timeConversion(string s) {
    char hour_c[2] = {s[0], s[1]};
    int hour_i = atoi(hour_c);
    if (s[8]=='P' && s[9] == 'M'){
        hour_i = (hour_i % 12) + 12; 
    } else {
        hour_i = (hour_i % 12); 
    }
    s[0] = (hour_i/10)+'0';
    s[1] = (hour_i%10)+'0';
    s.erase(8);
    return s;
}

int main()
{

    string s;
    getline(cin, s);
    string result = timeConversion(s);

    ofstream fout(getenv("OUTPUT_PATH"));
    fout << result << "\n";
    fout.close();

    return 0;
}
