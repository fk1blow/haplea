import { Component, OnInit, Input } from '@angular/core';
import { format } from 'date-fns';
import { ro } from 'date-fns/locale'
import { BehaviorSubject } from 'rxjs';
import { debounceTime, map } from 'rxjs/operators';

@Component({
  selector: 'hap-expense-item',
  templateUrl: './expense-item.component.html',
  styleUrls: ['./expense-item.component.scss']
})
export class ExpenseItemComponent implements OnInit {

  @Input() entries: string[]

  @Input() createdAt: Date

  expensesRow$ = new BehaviorSubject<string[]>([])

  expenseTotalSum = 0

  constructor() { }

  get entryDate() {
    return format(this.createdAt, 'EEEE d MMMM yyyy', { locale: ro })
  }

  get expenseItems() {
    return this.expensesRow$.value
  }

  ngOnInit() {
    this.expensesRow$
      .pipe(
        debounceTime(1000),
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
    this.expensesRow$.next(items)
  }

}
