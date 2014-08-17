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
    auto regexp = regex(`<a name="(.*)"><\/a>`);
    Keyword[] result;
    foreach(line; f.byLine())
    {
        auto m = match(line, regexp);
        if (m) {
            auto str = to!string(m.captures[1]);
            auto fullStr = section ~ "." ~ str;
            auto link = fileName ~ "#" ~ str;
            result ~= Keyword(str, fullStr, link);
        }
    }
    return result;
}

int main(string[] args)
{
    string htmlDirectory;
    string htmlPattern;
    string qhpFilename;
    getopt(args, "input|i", &htmlDirectory, "output|o", &qhpFilename, "pattern|p", &htmlPattern);
    if (htmlDirectory.length == 0 || qhpFilename.length == 0)
    {
        usage(args[0]);
        return 1;
    }
    if (htmlPattern.length == 0)
    {
        htmlPattern = "*.html";
    }

    string[] fileNames;
    string[] sections;
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
            sections ~= section;
        }
    }
    writeln(sections);
    return 0;
}
