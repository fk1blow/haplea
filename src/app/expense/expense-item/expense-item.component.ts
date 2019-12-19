import { Component, OnInit, Input } from '@angular/core';
import { parseISO, format } from 'date-fns';
import { ro } from 'date-fns/locale'

@Component({
  selector: 'hap-expense-item',
  templateUrl: './expense-item.component.html',
  styleUrls: ['./expense-item.component.scss']
})
export class ExpenseItemComponent implements OnInit {

  @Input() entries: string[]

  @Input() createdAt: Date

  get entryDate() {
    return format(this.createdAt, 'EEEE d MMMM yyyy', { locale: ro })
  }

  constructor() { }

  ngOnInit() {
  }

}
