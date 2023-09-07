using namespace std;
#include <cstdlib>
#include <iostream>
#include <string>
#include <unistd.h>
#include <vector>
#include <sstream>
#include <sys/wait.h>
#include <fcntl.h>
#include <algorithm>
#include<bits/stdc++.h>

// tokenizes the string command
// ex.) command = "hello world \t > hey"
// vector = {"hello", "world", ">", "hey"}
vector<string> tokenize(string &command) {
    // whitespaces = ' ', '\t', and '\v'
    // first, replace all the '\t' and '\v' as ' '
    char h_tab = '\t';
    char v_tab = '\v';
    char replacement = ' ';
    //reference: algorithm class with REPLACE function
    replace(command.begin(), command.end(), h_tab, replacement); //replaces all h_tabs to ' '
    replace(command.begin(), command.end(), v_tab, replacement); //replaces all h_tabs to ' '

    // next, go through string via delimiter -- reference: https://www.geeksforgeeks.org/tokenizing-a-string-cpp/#
    // start
    vector<string> tokens;
    stringstream check1(command);
    string intermediate;
    while(getline(check1, intermediate, replacement)) {
        tokens.push_back(intermediate);
    }
    // cout << "token size: " << tokens.size() << endl;
    for(unsigned int i = 0; i < tokens.size(); i++) {
        // cout << "arg: " << tokens[i] << " (len = " << tokens[i].length() << ")" << endl;
        //remove any blank spaces
        if (tokens[i].length() == 0) {
        // if (tokens[i] == " " | tokens[i] == "\t" | tokens[i] == "\v") {
            // cout << "   removing: " << tokens[i] << endl;
            tokens.erase(tokens.begin() + i);
            i = -1;
        }
    }

    return tokens;
}

// this function returns bool (true) iff the command is malformed, according to instructions

bool malformed(string& command) {
    vector<string> tokens = tokenize(command);
    int countGreater = 0;
    int countLesser = 0;
    for (unsigned int i = 0; i < tokens.size(); i++) {
        if ((tokens[i] == "<") | (tokens[i] == ">")) {
            if (tokens[i] == "<") {
                countGreater++;
            } else { 
                countLesser++;
            }

            if (i == tokens.size() - 1) {
                return true;
            } else {
                if ((tokens[i + 1] == "<") | (tokens[i + 1] == ">")) {
                    return true;
                }
            }

        }
    }
    
    //at most one of each...
    if ((countGreater > 1) | (countLesser > 1)) {
        return true;
    }

    //a non-malformed line will have at least one word, which you can check by removing the ops words too
    if (tokens.size() - countGreater*2 - countLesser*2 <= 0) {
        return true;
    }

    return false;
}

// get index of specified operator, ie < and >
int get_op_index(string& input, char op) {
    vector<string> tokens = tokenize(input);
    for (unsigned int i = 0; i < tokens.size(); i++) {
        if (tokens[i].length() == 1) {
            if (tokens[i][0] == op) {
                return i;
            }
        }
    }
    return -5;
}

// get first word that is not operator / part of redirection
int get_command_word(string& input) {
    vector<string> tokens = tokenize(input);
    for (unsigned int i = 0; i < tokens.size(); i++) {
        if ( (i == 0) & (tokens[i] != "<") & (tokens[i] != ">") ) {
            return 0;
        }
        if (i != 0) {
            // look behind to check if part of redirection
            if ( (tokens[i] != "<") & (tokens[i] != ">") & (tokens[i - 1] != "<") & (tokens[i - 1] != ">") ) {
                return i;
            }
        }

    }
    return 0;
}

// void parse_and_run_command(const std::string &command) {
//     /* TODO: Implement this. */
//     /* Note that this is not the correct way to test for the exit command.
//        For example the command "   exit  " should also exit your shell.
//      */
//     const char* executablePath = command.c_str();
//     const char* arguments[] = {executablePath, NULL};
//     cout << "Executing: " << command << endl;
    
//     int r = execv(executablePath, (char* const*)arguments);
//     cout << "Executed" << endl;
//     std::cerr << "Not implemented.\n";
// }

int main(void) {
    bool DEBUG = false;
    std::string command;
    std::cout << "> ";
    while (std::getline(std::cin, command)) {
        if (command == "exit") {
            break;
        }
        // if command is malformed, exit
        if (malformed(command) == true) {
            cerr << "invalid command" << endl;
            break;
        }
        vector<string> tokens = tokenize(command);
        
        pid_t pid = fork();
        if (pid == 0) {
            
            unsigned int command_int = get_command_word(command);
            const char* executablePath = tokens[command_int].c_str();
            //check for input and output redirection operations
            int input_op = get_op_index(command, '<');
            int output_op = get_op_index(command, '>');
            
            // const char* arguments[] = {};
            vector<const char*> arguments;
            arguments.push_back(executablePath);
            if (DEBUG) {
                cout << "command word: " << tokens[command_int] << endl;
                cout << "tokens -------" << endl;
                for (unsigned int i = 0; i < tokens.size(); i++ ) {
                    cout << "token" << i << ": " << tokens[i] << endl;
                }
                cout << "input op: " << input_op << endl;
                cout << "output op: " << output_op << endl;
            }

            for (unsigned int j = 0; j < tokens.size(); j++) {
                if ( (j != command_int) & ((int)j != input_op) & ((int)j != output_op) & ((int)j != input_op + 1) & ((int)j != output_op + 1) ) {
                    // add argument
                    arguments.push_back(tokens[j].c_str());
                }
            }
            arguments.push_back(nullptr);
            // https://cplusplus.com/reference/vector/vector/data/
            const char* const* argv = arguments.data();
            int input_fd;
            if (input_op != -5) {
                // open file -- the file should be the next index
                if ((input_fd = open(tokens[input_op + 1].c_str(), O_RDONLY)) != -1) {
                    // redirect stin to input file
                    dup2(input_fd, STDIN_FILENO);
                    close(input_fd);
                } else {
                    cerr << "error in opening file / does not exist" << endl;
                    return -1;
                }
            }

            int output_fd;
            if (output_op != -5) {
                // https://man7.org/linux/man-pages/man2/open.2.html for open()
                if ((output_fd = open(tokens[output_op + 1].c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0666)) != -1) {
                    dup2(output_fd, STDOUT_FILENO);
                    close(output_fd);
                } else {
                    cerr << "error in opening file / does not exist" << endl;
                    return -1;
                }
            }

            int r = execv(executablePath, (char* const*)argv);
            if (r < 0) { //error in execution
                cerr << command << "Command not found." << endl;
                return -1;
                // break;
            }
        } else if (pid > 0) {
            int status;
            pid_t child_pid = waitpid(pid, &status, 0);
            if (child_pid < 0) { //error
                break;
            }
            // https://man7.org/linux/man-pages/man2/wait.2.html -- reference for waitpid and use of status / wifexited/wifsignaled
            if (WIFEXITED(status)) {
                cout << command << " exit status: " << WEXITSTATUS(status) << endl;
            }
            //  else if (WIFSIGNALED(status)) {
            //     cerr << command << " exit status: " << WEXITSTATUS(status) << endl;
            // }

        } else { //fork error
            cerr << "fork error" << endl;
            std::cout << "> ";
            return -1;
        }
        std::cout << "> ";
    }
    return 0;
}


