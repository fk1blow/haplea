import { CommanderComponent } from './commander.component';
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';

@NgModule({
  declarations: [CommanderComponent],
  imports: [
    CommonModule
  ],
  exports: [
    CommanderComponent
  ]
})
export class CommanderModule { }
