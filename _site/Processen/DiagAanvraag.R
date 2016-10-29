###
# Create a graph with both nodes and edges
# defined, and, add some default attributes
# for nodes and edges
###

library(DiagrammeR)
library(gsheet)

edgeData <-
  gsheet2tbl(
    'https://docs.google.com/spreadsheets/d/1FMsrHWMamGdurh2b3Oz3RQVk6QkOFl5NZQ3wm2fGTVo/pubhtml?gid=0&single=true&outout=csv'
  )

nodeData <-
  gsheet2tbl(
    'https://docs.google.com/spreadsheets/d/1FMsrHWMamGdurh2b3Oz3RQVk6QkOFl5NZQ3wm2fGTVo/pub?gid=887688557&single=true&output=csv'
  )

edgeData$From_node <- gsub(" ", "\n", edgeData$From_node)
edgeData$To_node <- gsub(" ", "\n", edgeData$To_node)
nodeData$Name <- gsub(" ", "\n", nodeData$Name)
nodeData$Text <- paste0(nodeData$Text)

# Create a node data frame
nodes <-
  create_nodes(
    nodes = nodeData$Name,
    label = FALSE,
    type = "lower",
    color = nodeData$Color,
    shape = nodeData$Shape,
    width = 1,
    fixedsize = "false",
    fontsize = 10,
    tooltip = nodeData$Text
  )

edges <-
  create_edges(
    from = edgeData$From_node,
    to = edgeData$To_node,
    color = edgeData$Color,
    label = edgeData$Value,
    penwidth = 2,
    fontsize = 8,
    style=edgeData$Style
  )

graph <-
  create_graph(
    nodes_df = nodes,
    edges_df = edges,
    graph_attrs = c("layout = dot", "rankdir = LR", "label = 'Proces: Klantaanvraag'", "labelloc = 't'"),
    node_attrs = "fontname = Helvetica",
    edge_attrs = c("arrowsize = 0.6", "fontname = Helvetica")
  )

# Examine the NDF within the
# graph object
graph$nodes_df


graph$edges_df

render_graph(graph)