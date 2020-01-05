import { Component, OnInit } from '@angular/core';
import { Expense, ExpenseService } from '../expense/expense.service';
import { format, parseISO } from 'date-fns';

import { ro } from 'date-fns/locale';

@Component({
  selector: 'hap-dashboard-page',
  templateUrl: './dashboard-page.component.html',
  styleUrls: ['./dashboard-page.component.scss']
})
export class DashboardPageComponent implements OnInit {

  expenses: Expense[] = []

  constructor(private expenseService: ExpenseService) { }

  formatExpenseOn(date: string) {
    return format(parseISO(date), 'EEEE d MMMM yyyy', { locale: ro })
  }

  ngOnInit() {
    this.expenseService
      .all()
      .subscribe(r => {
        this.expenses = r
      })
  }

}
