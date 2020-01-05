import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { QuestionInputComponent } from './question-input.component';

@NgModule({
  declarations: [QuestionInputComponent],
  imports: [
    CommonModule
  ],
  exports: [
    QuestionInputComponent
  ]
})
export class QuestionInputModule { }
