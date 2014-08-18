#!/usr/bin/rdmd

import std.stdio;
import std.exception;
import std.conv;
import std.file;
import std.getopt;
import std.regex;

void usage(string app)
{
    writeln(app, " --input|-i input_dir --output|-o qhp_file [--patern|-p files_pattern]");
}

string parseSection(File f)
{
    auto regexp = regex(r"<h1>(.*)</h1>");
    foreach(line; f.byLine())
    {
        auto m = match(line, regexp);
        if (m) {
            return to!string(m.captures[1]);
        }
    }
    enforce(0, "Header not found");
    return "";
}

struct Keyword
{
    string name;
    string id;
    string link;
    this(const string n, const string i, const string l) {
        name = n;
        id = i;
        link = l;
    }
}

auto parseKeywords(File f, const string fileName, const string section)
{
    auto regexp = regex(`<a name="([^"]*)"><\/a>`);
    Keyword[] result;
    foreach(line; f.byLine())
    {
        auto m = match(line, regexp);
        if (m) {
            auto name = to!string(m.captures[1]);
            auto id1 = "D/" ~ section ~ "." ~ name;
            auto id2 = "D/" ~ name;
            auto link = fileName ~ "#" ~ name;
            result ~= Keyword(name, id1, link);
            result ~= Keyword(name, id2, link);
        }
    }
    return result;
}

struct Section
{
    string name;
    string link;
    this(const string n, const string l)
    {
        name = n;
        link = l;
    }
}

void generateQhp(File f, const string vers, const string[] files, const Section[] sections, const Keyword[] keywords)
{
    f.writeln(`<?xml version="1.0" encoding="UTF-8"?>
    <QtHelpProject version="1.0">
    <namespace>dlang.org.phobos.` ~ vers ~ `</namespace>
      <virtualFolder>phobos</virtualFolder>
      <customFilter name="Dlang Reference">
        <filterAttribute>phobos</filterAttribute>
        <filterAttribute>` ~ vers ~ `</filterAttribute>
      </customFilter>
      <filterSection>
        <filterAttribute>phobos</filterAttribute>
        <filterAttribute>` ~ vers ~ `</filterAttribute>
        <toc>
          <section title="Dlang Index" ref="index.html">`);
    foreach(s; sections)
    {
        f.writeln(`          <section title="` ~ s.name ~ `" ref="` ~ s.link ~ `"/>`);
    }
    f.writeln(`          </section>`);
    f.writeln(`        </toc>`);
    f.writeln(`        <keywords>`);
    foreach(k; keywords)
    {
        f.writeln(`         <keyword name="` ~ k.name ~ `" id="` ~ k.id ~ `" ref="` ~ k.link ~ `"/>`);
    }
    f.writeln(`        </keywords>`);
    f.writeln(`        <files>`);
    foreach(file; files)
    {
        f.writeln(`          <file>` ~ file ~ `</file>`);
    }
    f.writeln(`        </files>`);
    f.writeln(`      </filterSection>`);
    f.writeln(`    </QtHelpProject>`);
}

int main(string[] args)
{
    string htmlDirectory;
    string htmlPattern;
    string qhpFileName;
    getopt(args, "input|i", &htmlDirectory, "output|o", &qhpFileName, "pattern|p", &htmlPattern);
    if (htmlDirectory.length == 0 || qhpFileName.length == 0)
    {
        usage(args[0]);
        return 1;
    }
    if (htmlPattern.length == 0)
    {
        htmlPattern = "*.html";
    }

    string[] fileNames;
    Section[] sections;
    Keyword[] keywords;

    auto inFiles = dirEntries(htmlDirectory, htmlPattern, SpanMode.depth);
    foreach(f; inFiles)
    {
        if (f.isFile())
        {
            writeln(f.name());
            auto fi = File(f.name(), "r");
            fileNames ~= f.name();
            auto section = parseSection(fi);
            keywords ~= parseKeywords(fi, f.name(), section);
            sections ~= Section(section, f.name());
        }
    }
    auto qhp = File(qhpFileName, "w");
    generateQhp(qhp, "2.065", fileNames, sections, keywords);
    return 0;
}
