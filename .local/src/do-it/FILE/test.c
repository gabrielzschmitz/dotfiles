#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXPROJECTS 25
#define MAXTODOS 25
#define INDENTATION_SPACES "  "
#define PROJECT_CHAR '+'

// Defining the todo's struct
typedef struct todo todo;
struct todo{
    char *title;
    char deadline[9];
    int urgency;
};

// Defining the projects struct
typedef struct project project;
struct project{
    char *title;
    todo *todos[MAXTODOS];
    struct project *subproject;
};

// Defining the projects struct
typedef struct projectlist projectlist;
struct projectlist{
    project *projects[MAXPROJECTS];
};

// Function to create a new project
project *createProject(){
    project *newProject = (project *)malloc(sizeof(project));
    newProject->subproject = NULL;
    newProject->title = NULL;
    return newProject;
}

// Function to create a new project list
projectlist *createProjectList(){
    projectlist *newList = (projectlist *)malloc(sizeof(projectlist));
    return newList;
}

// Function to deserialize a file
void deserializeProjects(FILE *file, project *proj, int indent, projectlist *list, int projectIndex) {
    int totalIndent = (indent + 1) * strlen(INDENTATION_SPACES);
    char line[128];

    if(indent == 0 && projectIndex == 0){
        proj->title = (char *)malloc(sizeof(char) * 128);
        fgets(line, sizeof(line), file);
        sscanf(line + 1, "%[^:]", proj->title);
    }

    int todoIndex = 0;
    while(fgets(line, sizeof(line), file)){
        if(strstr(line, "- title:") != NULL){
            proj->todos[todoIndex] = (todo *)malloc(sizeof(todo));
            proj->todos[todoIndex]->title = (char *)malloc(sizeof(char) * 128);

            strncpy(proj->todos[todoIndex]->title, line + totalIndent + sizeof("- title:"), 128);
            strtok(proj->todos[todoIndex]->title, "\n");

            fgets(line, sizeof(line), file);
            sscanf(line + totalIndent + sizeof("deadline: "), "%8s", proj->todos[todoIndex]->deadline);

            fgets(line, sizeof(line), file);
            sscanf(line + totalIndent + sizeof("urgency: "), "%d", &(proj->todos[todoIndex]->urgency));

            todoIndex++;
        }else if(line[totalIndent] == PROJECT_CHAR && line[totalIndent - 1] == ' '){
            proj->subproject = createProject();
            proj->subproject->title = (char *)malloc(sizeof(char) * 128);
            sscanf(line + totalIndent + 1, "%[^:]", proj->subproject->title);
            deserializeProjects(file, proj->subproject, indent + 1, list, projectIndex);
        }
        if(line[0] == PROJECT_CHAR){
            projectIndex = projectIndex + 1;
            list->projects[projectIndex] = createProject();
            list->projects[projectIndex]->title = (char *)malloc(sizeof(char) * 128);
            sscanf(line + 1, "%[^:]", list->projects[projectIndex]->title);
            deserializeProjects(file, list->projects[projectIndex], 0, list, projectIndex);
        }
    }
}

// Function to serialize a todo item
void serializeTodoItem(FILE *file, todo *item, int indent){
    int totalIndent = indent + 1;

    // Print indentation spaces
    for(int i = 0; i < indent; i++)
        fputs(INDENTATION_SPACES, file);
    
    // Print the title
    fprintf(file, "- title: %s\n", item->title);

    // Print indentation spaces for deadline and urgency 
    for(int i = 0; i < totalIndent; i++)
        fputs(INDENTATION_SPACES, file);

    // Print the deadline
    fprintf(file, "deadline: %s\n", item->deadline);

    // Print the urgency (only if indent > 0)
    if(indent > 0){
        for(int i = 0; i < totalIndent; i++)
            fputs(INDENTATION_SPACES, file);

        fprintf(file, "urgency: %d\n", item->urgency);
    }
}

// Function to serialize a project
void serializeProject(FILE *file, project *proj, int indent){
    int totalIndent = indent + 1;

    for(int i = 0; i < indent; i++)
        fputs(INDENTATION_SPACES, file);

    fprintf(file, "%c", PROJECT_CHAR);
    fprintf(file, "%s:\n", proj->title);

    for(int i = 0; i < MAXTODOS && proj->todos[i] != NULL && proj->todos[i]->title != NULL; i++)
        serializeTodoItem(file, proj->todos[i], totalIndent);

    if(proj->subproject != NULL)
        serializeProject(file, proj->subproject, totalIndent);
}

int main(int argc, char *argv[]){
    // Create a project
    projectlist *list1 = createProjectList();
    list1->projects[0] = createProject();
    list1->projects[0]->title = malloc(sizeof("PROJECT") + 1);
    strcpy(list1->projects[0]->title, "PROJECT");

    // Set details for the first todo item in list1
    list1->projects[0]->todos[0] = (todo *)malloc(sizeof(todo *));
    list1->projects[0]->todos[0]->title = malloc(sizeof("task1") + 1);
    strcpy(list1->projects[0]->todos[0]->title, "task1");
    strcpy(list1->projects[0]->todos[0]->deadline, "24/08/23");
    list1->projects[0]->todos[0]->urgency = 2;

    // Set details for the second todo item in list1
    list1->projects[0]->todos[1] = (todo *)malloc(sizeof(todo *));
    list1->projects[0]->todos[1]->title = malloc(sizeof("task2") + 1);
    strcpy(list1->projects[0]->todos[1]->title, "task2");
    strcpy(list1->projects[0]->todos[1]->deadline, "25/08/23");
    list1->projects[0]->todos[1]->urgency = 1;
    
    // Create a subproject
    list1->projects[0]->subproject = createProject();
    list1->projects[0]->subproject->title = malloc(sizeof("SUBPROJECT") + 1);
    strcpy(list1->projects[0]->subproject->title, "SUBPROJECT");

    // Set details for the todo item in the subproject
    list1->projects[0]->subproject->todos[0] = (todo *)malloc(sizeof(todo *));
    list1->projects[0]->subproject->todos[0]->title = malloc(sizeof("task1") + 1);
    strcpy(list1->projects[0]->subproject->todos[0]->title, "task1");
    strcpy(list1->projects[0]->subproject->todos[0]->deadline, "23/08/23");
    list1->projects[0]->subproject->todos[0]->urgency = 5;

    // Opening file
    FILE *file = fopen("project.yaml", "w");
    if(file == NULL) {
        printf("Failed to open the file for writing.\n");
        return 1;
    }

    // Serialize the project to the file
    serializeProject(file, list1->projects[0], 0);

    // Closing file
    fclose(file);

    // Opening file
    file = fopen("project.yaml", "r");
    if(file == NULL) {
        printf("Failed to open the file for writing.\n");
        return 1;
    }

    // Deserialize the file to the project
    projectlist *list2 = createProjectList();
    list2->projects[0] = createProject();
    deserializeProjects(file, list2->projects[0], 0, list2, 0);
    fclose(file);

    file = fopen("project.yaml", "a+");
    if(file == NULL) {
        printf("Failed to open the file for writing.\n");
        return 1;
    }
    serializeProject(file, list2->projects[0], 0);
    fclose(file);

    file = fopen("project.yaml", "r");
    if(file == NULL) {
        printf("Failed to open the file for writing.\n");
        return 1;
    }
    projectlist *list3 = createProjectList();
    list3->projects[0] = createProject();
    deserializeProjects(file, list3->projects[0], 0, list3, 0);

    return 0;
}
