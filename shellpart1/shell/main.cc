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
#include <cstring>
#include <unistd.h>
#include <sys/wait.h>

//reference: https://stackoverflow.com/questions/14265581/parse-split-a-string-in-c-using-string-delimiter-standard-c
// Helper method to parse a string by delimiter -- used explictly for pipes... " | "
vector<string> split(string s, string delimiter) {
    size_t pos_start = 0, pos_end, delim_len = delimiter.length();
    std::string token;
    std::vector<std::string> res;

    while ((pos_end = s.find(delimiter, pos_start)) != std::string::npos) {
        token = s.substr (pos_start, pos_end - pos_start);
        pos_start = pos_end + delim_len;
        res.push_back (token);
    }

    res.push_back (s.substr (pos_start));
    return res;
}

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


int main(void) {
    // bool DEBUG = true;
    std::string command;
    std::cout << "> ";
    while (std::getline(std::cin, command)) {
        if (command == "") {
            cout << "> ";
            continue;
        }
        if (command == "exit") {
            break;
        }
        vector<string> tokens = tokenize(command);
        if ((tokens[tokens.size() - 1] == "|") | (tokens[0] == "|")) {
            cerr << "invalid command" << endl;
            cout << "> ";
            continue;
        }

        string delimiter = " | ";
        vector<string> pipeline_commands = split (command, delimiter);
        bool malformed_pipeline = false;
        for (unsigned int z = 0; z < pipeline_commands.size(); z++) {
            // check each command -- check if malformed
            if (malformed(pipeline_commands[z]) == true) {
                // cout << pipeline_commands[z] << " exit status: 255" << endl;
                cerr << "invalid command" << endl;
                // return -1;
                malformed_pipeline = true;
            }
        }  

        if (malformed_pipeline == true) {
            cout << "> ";
            continue;
        }

        unsigned int num_pipeline_commands = pipeline_commands.size();
        int pipes[num_pipeline_commands][2];
        vector<pid_t> pids;
        for (unsigned int p = 0; p < num_pipeline_commands; p++) {
            // create pipes for all pipe commands
            if (p < num_pipeline_commands - 1) {
                if (pipe(pipes[p]) == -1) {
                    cerr << "Pipe creation error" << endl;
                    return -1;
                    // break;
                }
            }
        }
        for (unsigned int p = 0; p < num_pipeline_commands; p++) {
        tokens = tokenize(pipeline_commands[p]);
        command = pipeline_commands[p];
        pid_t pid = fork();
        pids.push_back(pid);
        if (pid == 0) {

            // if command is not the first in the pipeline, connect its stdin to stdout of previous pipeline
            unsigned int command_int = get_command_word(command);
            const char* executablePath = tokens[command_int].c_str();
            //check for input and output redirection operations
            // cout << "Command: " << tokens[command_int] << endl;
            int input_op = get_op_index(command, '<');
            int output_op = get_op_index(command, '>');
            
            // const char* arguments[] = {};
            vector<const char*> arguments;
            arguments.push_back(executablePath);
            
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

            if (p > 0) { // if it's not the first pipe
                dup2(pipes[p - 1][0], STDIN_FILENO); 
                close(pipes[p - 1][1]); //close write end
                close(pipes[p - 1][0]); //close read end
            }

            if (p < num_pipeline_commands - 1) { //if it's not the last pipeline
                dup2(pipes[p][1], STDOUT_FILENO); // set STDOUT 
                close(pipes[p][0]); //close read end
                close(pipes[p][1]); //close write end
            }
            
            int r = execv(executablePath, (char* const*)argv);

            //ignore pipelined commands 
            if ((r < 0) & (num_pipeline_commands == 1)) { //error in execution
                cerr << "Command not found." << endl;
                return -1;
            }





            return 0;
        } else if (pid > 0) {
            if (p > 0) {
                close(pipes[p - 1][0]);
                close(pipes[p - 1][1]);
            }
            // for (int v = 0; v < num_pipeline_commands; v++) {
            //     close(pipes[v][0]);
            //     close(pipes[v][1]);    
            // }
        } else { //fork error
            cerr << "fork error" << endl;
            std::cout << "> ";
            return -1;
        }   

    }


    
    for (unsigned int i = 0; i < num_pipeline_commands; i++) {
        
        int status;
        pid_t child_pid = waitpid(pids[i], &status, 0);
        if (child_pid < 0) { //error
            break;
        }
        // https://man7.org/linux/man-pages/man2/wait.2.html -- reference for waitpid and use of status / wifexited/wifsignaled
        if (WIFEXITED(status)) {
            // cout << tokens[get_command_word(command)] << " exit status: " << WEXITSTATUS(status) << endl;
            cout << tokenize(pipeline_commands[i])[get_command_word(pipeline_commands[i])] << " exit status: " << WEXITSTATUS(status) << endl;
        }
    }


    cout << "> ";
    }
    return 0;
}

