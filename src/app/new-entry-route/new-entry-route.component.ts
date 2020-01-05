import { Component, HostListener, OnInit } from '@angular/core';
import { debounceTime, map, startWith, mergeMap, timeout, delay, take, switchMap, skip, tap } from 'rxjs/operators';
import { format, parseISO } from 'date-fns';

import { ActivatedRoute } from '@angular/router';
import { BehaviorSubject, Subject, interval, merge, of } from 'rxjs';
import { ExpenseService } from '../expense/expense.service';
import { ro } from 'date-fns/locale';
// import { Either, Left, Right } from 'funfix-core'

@Component({
  selector: 'hap-new-entry-route',
  templateUrl: './new-entry-route.component.html',
  styleUrls: ['./new-entry-route.component.scss']
})
export class NewEntryRouteComponent implements OnInit {

  expenseItems$ = new BehaviorSubject<string>('')

  onSaveValidation$ = new Subject<boolean>()

  expenseSum = 0

  validationState = false

  // entryErrors: Either<string, string> = Right('ok')

  get hasExpenseItems() {
    return this.expenseItems$.value.length
  }

  constructor(
    private route: ActivatedRoute,
    private expenseService: ExpenseService
  ) { }

  @HostListener('document:keydown.meta.s',['$event'])
  onSaveMac(evt) {
    evt.preventDefault()

    const entryValid = this.expenseItems$.value.length < 1
    const expenseSumValid = this.expenseSum < 1

    this.onSaveValidation$.next(entryValid || expenseSumValid)



    // console.log('entryValid: ', entryValid);

    // entryValid
    //   .swap()
    //   .chain(() => expenseSumValid.swap())
      // .getOrElse((x) => {
      //   console.log('x: ', x);
      // })

    // this.onSaveValidation$.next(entryValid)

    // if (entryValid) {
      // this.expenseService.create({
      //   on: this.route.snapshot.paramMap.get('date'),
      //   sum: this.expenseSum,
      //   items: this.expenseItems$.value
      // })
    // }
  }

  get entryDate() {
    const date = this.route.snapshot.paramMap.get('date')
    return format(parseISO(date), 'EEEE d MMMM yyyy', { locale: ro })
  }

  ngOnInit() {
    this.expenseItems$
      .pipe(
        debounceTime(300),
        map(raw => raw.split('\n').filter(l => l.length !== 0)),
        map(items => items.join('').match(/(([0-9]+\.|\,)?[0-9]+\s+(lei|ron))/g)),
        map((matches: null | string[]) =>{
          if (matches === null) return 0;
          return matches
            .map(x => x.replace(',', '.'))
            .map(x => parseFloat(x))
            .reduce((acc, next) => acc + next, 0)
        })
      )
      .subscribe(sum => this.expenseSum = sum)

    this.onSaveValidation$
      .pipe(
        switchMap(v =>
          merge(
            of(v),
            of(false).pipe(delay(1000), take(1)),
            this.expenseItems$.pipe(skip(1), take(1), mergeMap(() => of(false)))
          ),
        )
      )
      .subscribe(state => this.validationState = state)
  }

  onEditorChange(raw: string) {
    this.expenseItems$.next(raw)
  }

}
