```C
#include "playlist.h"

typedef struct playlist_node_s {
    uint32_t id;
    char artist[MAX_ARTIST_LENGTH];
    char title[MAX_TITLE_LENGTH];
    struct playlist_node_s *next;
}node_t;

int insert_at_end(node_t *head, node_t *new_node)
{
    if ( head == NULL || new_node == NULL ) 
        return -1;

    node_t *current = head;
    while (current->next != NULL)
    {
        current = current->next;
    }
    current->next = new_node;
    new_node->next = NULL;
    return 0;
}

int insert_after_pos(node_t *head, node_t *new_node, size_t pos)
{
    if (head == NULL || new_node == NULL)
        return -1;

    node_t *current = head;

    size_t cnt = 0;
    while (current != NULL)
    {
        if (pos == cnt++)
        {
            new_node->next = current->next;
            current->next = new_node;
            return 0;
        }
        current = current->next;
    }
    return -1;
}

int count_elements(node_t *head)
{
    if (head == NULL)
        return 0;

    node_t *current = head;

    size_t cnt = 0;
    while (current != 0)
    {
        cnt ++;
        current = current->next;
    }
    return (int)cnt;    
}

node_t *get_element(node_t *head, size_t pos)
{
    if (!head)
        return NULL;

    node_t *current = head;
    size_t cnt = 0;
    while (current != 0)
    {
        if (pos == cnt++)
        {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void print_playlist(node_t *head)
{
    node_t *current = head;
    int ctr = 0;
    while (current != NULL)
    {
        // printf("%p : %p ", current, current->next);
        printf("%d: ", ctr);
        printf("0x%X\n", current->id);
        // printf("Artist: %s\n", current->artist);
        // printf("Song: %s\n\n", current->title);
        current = current->next;
        ctr++;
    }
}

int remove_by_id(node_t *head, uint32_t id)
{
    if (head == NULL)
        return -1;

    node_t *current = head;
    node_t *previous = NULL;

    while (current != NULL)
    {
        if (current->id == id)
        {
            if (previous == NULL)
            {
                // The node to be removed is the head
                // continue as there might be another song with that id that could be removed
                // continue;
                // must return as test playlist_remove_by_id_first expects that 
                return -1;
            }
            else
            {
                // The node to be removed is not the head
                previous->next = current->next;
            }
            free(current);
            return 0;
        }
        previous = current;
        current = current->next;
    }
    // Song with the given ID not found in the playlist
    return -1;
}

int remove_by_pos(node_t *head, size_t pos)
{
    if (!head)
        return -1;


    node_t *current = head;
    node_t *previous = head;

    size_t cnt = 0;

    while (current != 0)
    {
        if (pos == cnt)
        {
            previous->next = current->next;
            free(current);
            return 0;
        }
        previous = current;
        current = previous->next;
        cnt++;
    }
    return -1;  
}

int move_up(node_t *head, size_t pos)
{
    // works for all pos >= 2 (in other cases head will have to be changed)
    // .next --> node
    // pos-2 --> pos
    // pos   --> pos-1
    // pos-1 --> pos+1
    
    if ( head == NULL )
        return -1;
    
    if ( pos < 2 )
        return -1;


    //TODO wtf is that, use loop and for pos_... use array??
    node_t* pos_n2 = get_element(head, pos-2);
    if ( pos_n2 == NULL )
        return -1;
    node_t* pos_n1 = pos_n2->next;
    if ( pos_n1 == NULL )
        return -1;
    node_t* pos_00 = pos_n1->next;
    if ( pos_00 == NULL )
        return -1;
    node_t* pos_p1 = pos_00->next;

    pos_n2->next = pos_00;
    pos_00->next = pos_n1;
    pos_n1->next = pos_p1;

    return 0;

}

int move_down(node_t *head, size_t pos)
{
    // just use move_up 
    return move_up(head, pos+1 );

}
```