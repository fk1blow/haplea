import { Component, Input, OnInit, ViewChild, Output, EventEmitter, HostListener } from '@angular/core';
import { debounceTime, map } from 'rxjs/operators';
import { format, parseISO } from 'date-fns';

import { BehaviorSubject } from 'rxjs';
import { EditorComponent } from 'src/app/editor/editor.component';
import { ro } from 'date-fns/locale'

@Component({
  selector: 'hap-expense-item',
  templateUrl: './expense-item.component.html',
  styleUrls: ['./expense-item.component.scss']
})
export class ExpenseItemComponent implements OnInit {

  @Input() createdAt: string

  @Input() autofocusEditor: boolean = false

  @Output() change = new EventEmitter<string[]>()

  @ViewChild('editor', { static: true }) editorRef: EditorComponent

  expenseSum$ = new BehaviorSubject<string[]>([])

  expenseTotalSum = 0

  constructor() { }

  get entryDate() {
    return format(parseISO(this.createdAt), 'EEEE d MMMM yyyy', { locale: ro })
  }

  get newExpenseItems() {
    return this.expenseSum$.value
  }

  ngOnInit() {
    this.expenseSum$
      .pipe(
        debounceTime(350),
        map(items => items.join('').match(/(([0-9]+\.|\,)?[0-9]+\s+(lei|ron))/g)),
        map((matches: null | string[]) =>{
          if (matches === null) return 0;
          return matches
            .map(x => x.replace(',', '.'))
            .map(x => parseFloat(x))
            .reduce((acc, next) => acc + next, 0)
        })
      )
      .subscribe(sum => this.expenseTotalSum = sum)
  }

  onEditorChange(items: string[]) {
    this.expenseSum$.next(items)
  }

}
