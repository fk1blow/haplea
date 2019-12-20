import { Component, OnInit, Input } from '@angular/core';
import { format } from 'date-fns';
import { ro } from 'date-fns/locale'

@Component({
  selector: 'hap-expense-item',
  templateUrl: './expense-item.component.html',
  styleUrls: ['./expense-item.component.scss']
})
export class ExpenseItemComponent implements OnInit {

  @Input() entries: string[]

  @Input() createdAt: Date

  expenseItems: string[] = []

  get entryDate() {
    return format(this.createdAt, 'EEEE d MMMM yyyy', { locale: ro })
  }

  // might be too expensive so refactor at some point
  get expenseTotalSum() {
    const matches: string[] = this.expenseItems
      .join('')
      .match(/([0-9]+(\.|\,)?[0-9]+\s+(lei|ron))/g)

    if (!matches) return 0;

    return matches
      .map(x => x.replace(',', '.'))
      .map(x => parseFloat(x))
      .reduce((acc, next) => acc + next, 0)
  }

  constructor() { }

  ngOnInit() {
  }

  onEditorChange(items: string[]) {
    this.expenseItems = items
  }

}
