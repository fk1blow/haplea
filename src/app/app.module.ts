import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { CommanderModule } from './commander/commander.module';
import { EditorModule } from './editor/editor.module';
import { QueryInterpreterModule } from './command-interpreter/command-interpreter.module';
import { NewEntryRouteComponent } from './new-entry-route/new-entry-route.component';

@NgModule({
  declarations: [
    AppComponent,
    NewEntryRouteComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    EditorModule,
    CommanderModule,
    HttpClientModule,
    QueryInterpreterModule
  ],
  providers: [
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
