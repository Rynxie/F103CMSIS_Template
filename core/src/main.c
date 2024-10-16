#include "main.h"

int main(){
    
    RCC->APB2ENR |= (1<<4);
    
    GPIOC->CRH   |= (1<<20);
    GPIOC->CRH   |= (1<<21);
    GPIOC->CRH   &= ~(1<<22);
    GPIOC->CRH   |= (1<<23);

    while(1){

    }

}