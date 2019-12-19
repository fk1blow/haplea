import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ExpenseItemComponent } from './expense-item/expense-item.component';
import { EditorModule } from '../editor/editor.module';

@NgModule({
  declarations: [ExpenseItemComponent],
  imports: [
    CommonModule,
    EditorModule
  ],
  exports: [
    ExpenseItemComponent
  ]
})
export class ExpenseModule { }
