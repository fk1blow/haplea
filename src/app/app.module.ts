import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { CommandInterpreterModule } from './command-interpreter/command-interpreter.module';
import { CommanderModule } from './commander/commander.module';
import { ExpenseModule } from './expense/expense.module';
import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';
import { DashboardPageComponent } from './dashboard-page/dashboard-page.component';
import { EditorModule } from './editor/editor.module';
import { QuestionInputModule } from './question-input/question-input.module';
import { ConversationModule } from './conversation/conversation.module';

@NgModule({
  declarations: [
    AppComponent,
    NewEntryRouteComponent,
    DashboardPageComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    CommanderModule,
    HttpClientModule,
    CommandInterpreterModule,
    ExpenseModule,
    EditorModule,
    QuestionInputModule,
    ConversationModule
  ],
  providers: [
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
