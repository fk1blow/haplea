import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, Subject, of } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';

import { Injectable } from '@angular/core';
import { IntentCommand } from './IntentCommand';
import { WitInterpreterService } from './wit-interpreter.service';

@Injectable({
  providedIn: 'root'
})
export class InputCommandsService {

  private intentStrategySink$ = new Subject<IntentCommand>()

  get intentCommand$() {
    return this.intentStrategySink$.asObservable() as Observable<IntentCommand>
  }

  constructor(
    private http: HttpClient,
    private commandInterpreter: WitInterpreterService
  ) { }

  recognize(input: string) {
    of(new HttpParams().set('v', '20191216').set('q', input))
      .pipe(
        switchMap(params =>
          this.http
            .get('https://api.wit.ai/message', {
              params,
              headers: {
                'Authorization': 'Bearer M4KQAFDQ5Z5MSFKGHO2JDSQKTJZVHJHD'
              }
            })
        ),

        map((res: { entities: Record<string, any> }) =>
          this.commandInterpreter.interpret(res.entities)
        )
      )
      .subscribe(this.intentStrategySink$)
  }
}
