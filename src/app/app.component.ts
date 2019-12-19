import { filter, map } from 'rxjs/operators';

import { Component } from '@angular/core';
import { InputCommandsService } from './command-interpreter/input-commands.service';
import NewEntryIntent from './command-interpreter/intent/NewEntryIntent';
import { Router } from '@angular/router';
import UndefinedIntent from './command-interpreter/intent/UndefinedIntent';
import { format } from 'date-fns';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'haplea';

  constructor(
    private inputComandsService: InputCommandsService,
    private router: Router
  ) {
    this.inputComandsService.intentCommand$
      .pipe(
        filter(intent => intent instanceof UndefinedIntent),
      )
      .subscribe((intent: UndefinedIntent) => {
        console.log('undefined intent')
      })

    this.inputComandsService.intentCommand$
      .pipe(
        filter(intent => intent instanceof NewEntryIntent),
      )
      .subscribe((intent: NewEntryIntent) => {
        this.router.navigate(
          [
            // not sure if this is an abstraction leak or...
            intent.description.path,
            format(intent.description.created, 'yyyy-MM-dd')
          ]
        )
      })
  }

  onCommanderInput(input: string) {
    if (input.trim().length < 1) {
      console.log('input cleared')
    }
    else {
      this.inputComandsService.recognize(input)
    }
  }
}
