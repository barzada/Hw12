#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main (int argc, char **argv) {
    pid_t pid = fork();
    if (pid == 0) {
        printf("child with pid = %d\n", getpid());
        execl("hello", "hello", "today is Monday\n", (char*) NULL);
    }
    else
        printf("parent with pid = %d, child has pid %d\n", getpid(), pid);
    return 0;
}