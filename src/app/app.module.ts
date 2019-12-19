import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { CommandInterpreterModule } from './command-interpreter/command-interpreter.module';
import { CommanderModule } from './commander/commander.module';
import { ExpenseModule } from './expense/expense.module';
import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';

@NgModule({
  declarations: [
    AppComponent,
    NewEntryRouteComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    CommanderModule,
    HttpClientModule,
    CommandInterpreterModule,
    ExpenseModule
  ],
  providers: [
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
