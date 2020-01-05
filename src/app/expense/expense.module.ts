import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ExpenseItemComponent } from './expense-item/expense-item.component';
import { EditorModule } from '../editor/editor.module';
import { ExpenseService } from './expense.service';

@NgModule({
  declarations: [ExpenseItemComponent],
  imports: [
    CommonModule,
    EditorModule
  ],
  providers: [
    ExpenseService
  ],
  exports: [
    ExpenseItemComponent
  ]
})
export class ExpenseModule { }
