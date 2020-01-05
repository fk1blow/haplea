import { Observable } from 'rxjs';

import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { map } from 'rxjs/operators';

export interface Expense {
  id?: number,
  on: string | Date,
  products?: string[],
  items: string[],
  sum: number
}

@Injectable({
  providedIn: 'root'
})
export class ExpenseService {

  constructor(private http: HttpClient) { }

  all(): Observable<Expense[]> {
    return this.http
      .get('http://localhost:4000/api/expenses')
      .pipe(
        map((res: { data: Expense[] }) => res.data)
      )
  }

  create(expense: Pick<Expense, 'on' | 'sum' | 'items'>) {
    return this.http
      .post('http://localhost:4000/api/expenses', {
        expense
      })
      .subscribe(r => {
        console.log('r: ', r);
      })
  }

}
